require './util_bstream_reader'
require './msg_types'
require './msg_query'
require './msg_reply'
require './msg_message'
require './msg_message_section'
require './socket_wrapper'
require 'zlib'

# Parses incoming messages
class MessageParser
    def self.parse(c)
        $logger.debug('METHOD_START:MessageParser.parse')
        c = SocketWrapper.new(c)

        std_header = StandardMessageHeader.new
        std_header.message_length = fetch_uint32(c)
        if std_header.message_length == nil
            $logger.info('Attempted to parse nil length data')
            return nil
        end
        std_header.request_id = fetch_uint32(c)
        std_header.response_to = fetch_uint32(c)
        std_header.op_code = fetch_uint32(c)

        $logger.info(std_header)

        if std_header.op_code == OP_QUERY
            $logger.info('Reading an OP_QUERY')
            query_msg = QueryMessage.new
            query_msg.header = std_header
          
            query_msg.flags = fetch_uint32(c)
            #coll_name = c.gets("\0").chomp("\0") #Cannot mix recv and gets
            query_msg.collection_name = read_to_char(c, "\0").chomp("\0")
            query_msg.num_skip = fetch_uint32(c)
            query_msg.num_return = fetch_uint32(c)
            read_so_far = 28 + query_msg.collection_name.length + 1
            
            remaining_len = std_header.message_length - read_so_far
            remaining_data = c.recv remaining_len

            #TODO: Separate the last 4 bits of the message for CRC32 (used for non-TLS/SSL traffic)
            bson_len = ((remaining_data.slice 0, 4).unpack 'V').first
            buffer = BSON::ByteBuffer.new(remaining_data.slice(0, bson_len))
            query_msg.doc = BSON::Document.from_bson(buffer)
                        
            optional_selector_len = remaining_len - (4 + bson_len + 1)
            #TODO Get the optional field_selector

            $logger.info(query_msg.doc)
            retval = query_msg
        elsif std_header.op_code == OP_REPLY
            $logger.info('Reading an OP_REPLY')
            reply_msg = ReplyMessage.new
            reply_msg.header = std_header  # 16 bytes
          
            reply_msg.flags = fetch_uint32(c)
            reply_msg.cursor_id = fetch_uint64(c)  
            reply_msg.start_from = fetch_uint32(c)
            reply_msg.num_return = fetch_uint32(c)

            read_so_far = 36
            
            remaining_len = std_header.message_length - read_so_far
            if remaining_len > 0
                remaining_data = c.recv remaining_len

                buffer = BSON::ByteBuffer.new(remaining_data)
                reply_msg.doc = BSON::Document.from_bson(buffer)
            else
                reply_msg.doc = BSON::Document.new
            end

            $logger.info(reply_msg.doc)
            retval = reply_msg
        elsif std_header.op_code == OP_MSG
            $logger.info('Reading an OP_MSG')
            msg_msg = MessageMessage.new
            msg_msg.header = std_header

            msg_msg.flags = fetch_uint32(c)

            first_section = MessageMessageSection.new
            first_section.kind = fetch_byte(c)
            if first_section.kind == 0
                read_so_far = std_header.my_size + 4 + 1
                remaining_len = std_header.message_length - read_so_far
                remaining_data = c.recv remaining_len

                # $logger.info("Read So Far: #{read_so_far} ; Remaining: #{remaining_len} ; BSON length: #{remaining_data[0]}")

                # bson_len = fetch_uint32(c)
                # bson_body = c.recv(bson_len+8)
                # bson_doc_raw = bson_len.chr + bson_body

                if msg_msg.flags == 1   #TODO: Do an AND with 1
                    crc = remaining_data.slice(remaining_data.length - 4, remaining_data.length)
                    $logger.debug("CRC: #{crc}")
                end

                buffer = BSON::ByteBuffer.new(remaining_data)
                first_section.doc = BSON::Document.from_bson(buffer)
                msg_msg.sections = [].append(first_section)

                $logger.info(msg_msg.sections[0].doc)
                retval = msg_msg
            else
                puts 'We cannot read kind 1 OP_MSG sections'
                retval = nil
            end
        elsif std_header.op_code == nil
            $logger.error('No op code')
            retval = nil
        else
            $logger.error('Unrecognized op code')
            $logger.error(std_header)
            p std_header
            raise Exception.new 'Unrecognized op code: ' #+ std_header.op_code.to_a
        end

        $logger.debug('METHOD_RETRN:MessageParser.parse')
        retval
    end
end