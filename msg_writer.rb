require './msg_query'
require './msg_reply'
require './socket_wrapper'
require 'digest/crc32c'

# Writes messages to the network
class MessageWriter
    def self.writeMessage(c, msg)
        $logger.debug('METHOD_START:MessageWriter.writeMessage')

        if msg == nil
            $logger.info('Attempted to write nil message')
            return
        end
        
        buf = ""

        c = SocketWrapper.new(c)

        msg.calculate_message_size
        $logger.info(msg.header)

        buf += [msg.header.message_length].pack('I')
        buf += [msg.header.request_id].pack('I')
        buf += [msg.header.response_to].pack('I')
        buf += [msg.header.op_code].pack('I')

        if msg.is_a?(ReplyMessage)
            $logger.info('Writing an OP_REPLY')
            $logger.info(msg.doc)

            buf += [msg.flags].pack('I')
            buf += [msg.cursor_id].pack('Q')
            buf += [msg.start_from].pack('I')
            buf += [msg.num_return].pack('I')

            bson_bytes = msg.doc_buffer.get_bytes(msg.doc_buffer.length)

            buf += bson_bytes
        elsif msg.is_a?(QueryMessage)
            $logger.info('Writing an OP_QUERY')
            $logger.info(msg.doc)

            buf += [msg.flags].pack('I')
            buf += msg.collection_name + "\0"
            buf += [msg.num_skip].pack('I')
            buf += [msg.num_return].pack('I')

            bson_bytes = msg.doc_buffer.get_bytes(msg.doc_buffer.length)

            buf += bson_bytes
        elsif msg.is_a?(MessageMessage)
            $logger.info('Writing an OP_MSG')
            $logger.info(msg.sections[0].doc)

            buf += [msg.flags].pack('I')

            msg.sections.each do |iter_section|
                buf += [iter_section.kind].pack('C')
                bson_bytes = iter_section.doc_buffer.get_bytes(iter_section.doc_buffer.length)
                buf += bson_bytes
            end

            crc = Digest::CRC32c.checksum(buf)
            $logger.debug("CRC: #{crc}")

            buf += [crc].pack('I')
        end

        c.send(buf, 0)

        $logger.debug('METHOD_RETRN:MessageWriter.writeMessage')
    end

    def self.writeMessage_legacy(c, msg)
        $logger.debug('METHOD_START:MessageWriter.writeMessage')
        c = SocketWrapper.new(c)

        msg.calculate_message_size
        $logger.info(msg.header)

        c.send([msg.header.message_length].pack('I'), 0)
        c.send([msg.header.request_id].pack('I'), 0)
        c.send([msg.header.response_to].pack('I'), 0)
        c.send([msg.header.op_code].pack('I'), 0)

        if msg.is_a?(ReplyMessage)
            $logger.info('Writing an OP_REPLY')
            $logger.info(msg.doc)
            c.send([msg.flags].pack('I'), 0)
            c.send([msg.cursor_id].pack('Q'), 0)
            c.send([msg.start_from].pack('I'), 0)
            c.send([msg.num_return].pack('I'), 0)
            
            bson_bytes = msg.doc_buffer.get_bytes(msg.doc_buffer.length)
            c.send(bson_bytes, 0)
        elsif msg.is_a?(QueryMessage)
            $logger.info('Writing an OP_QUERY')
            $logger.info(msg.doc)
            c.send([msg.flags].pack('I'), 0)
            c.send(msg.collection_name + "\0", 0)
            c.send([msg.num_skip].pack('I'), 0)
            c.send([msg.num_return].pack('I'), 0)

            bson_bytes = msg.doc_buffer.get_bytes(msg.doc_buffer.length)
            c.send(bson_bytes, 0)
        elsif msg.is_a?(MessageMessage)
            $logger.info('Writing an OP_MSG')
            $logger.info(msg.sections[0].doc)
            c.send([msg.flags].pack('I'), 0)
            msg.sections.each do |iter_section|
                c.send([iter_section.kind].pack('C'), 0)
                bson_bytes = iter_section.doc_buffer.get_bytes(iter_section.doc_buffer.length)
                c.send(bson_bytes, 0)
            end
        end
        $logger.debug('METHOD_RETRN:MessageWriter.writeMessage')
    end
end