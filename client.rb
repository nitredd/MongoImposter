require 'socket'
require './msg_query'
require './msg_reply'


class Client
    def initialize(port=27017)
        @counter_request_id = 0
        @port = port
    end


    def start
        c = TCPSocket.open('127.0.0.1', @port)

        std_header = StandardMessageHeader.new request_id: @counter_request_id
        @counter_request_id += 1



        #
        # isMaster
        #

        doc = BSON::Document.new(
            isMaster: 1,
            hostInfo: 'Nitins-MBP:27017',
            client: {
                application: {
                    name: 'MongoDB Shell'
                },
                driver: {
                    name: 'MongoDB Internal Client',
                    version: '4.2.2'
                },
                os: {
                    type: 'Darwin',
                    name: 'Mac OS X',
                    architecture: 'x86_64',
                    version: '19.5.0'
                }
            }
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # isMaster
        #

        doc = BSON::Document.new(
            ismaster: 1
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # whatsmyuri
        #

        doc = BSON::Document.new(
            whatsmyuri: 1
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # buildInfo
        #

        doc = BSON::Document.new(
            buildInfo: 1
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # startupWarnings
        #

        doc = BSON::Document.new(
            getLog: 'startupWarnings'
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # getFreeMonitoringStatus
        #

        doc = BSON::Document.new(
            getFreeMonitoringStatus: 1.0
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # buildInfo
        #

        doc = BSON::Document.new(
            buildInfo: 1.0
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # buildInfo
        #

        doc = BSON::Document.new(
            getCmdLineOpts: 1.0
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # replSetGetStatus
        #

        doc = BSON::Document.new(
            replSetGetStatus: 1.0,
            forShell: 1.0
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # listDatabases
        #

        doc = BSON::Document.new(
            listDatabases: 1.0,
            nameOnly: false
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # listCollections
        #

        doc = BSON::Document.new(
            listCollections: 1.0,
            filter: {},
            nameOnly: true,
            authorizedCollections: true
        )
        query_msg = QueryMessage.new(header: std_header, collection_name: "admin.$cmd", doc: doc)
        MessageWriter.writeMessage(c, query_msg)

        reply_msg = MessageParser.parse(c)



        #
        # test.cars
        #

        # doc = BSON::Document.new()
        # query_msg = QueryMessage.new(header: std_header, collection_name: "test.cars", doc: doc)
        # MessageWriter.writeMessage(c, query_msg)
        #
        # reply_msg = MessageParser.parse(c)



        #
        # OP_MSG {ismaster: true, $db: admin}
        #

        doc = BSON::Document.new(
            ismaster: true,
            '$db': 'admin'
        )
        section = MessageMessageSection.new(doc: doc)
        msg_msg = MessageMessage.new(header: std_header)
        msg_msg.sections.append section
        MessageWriter.writeMessage(c, msg_msg)

        reply_msg = MessageParser.parse(c)






        c.close

        # Display the document included in the message
        if reply_msg == nil
            print 'Reply length was nil'
        elsif reply_msg.class.method_defined? 'doc'
            p reply_msg.doc
        else
            if reply_msg.class.method_defined? 'sections' and reply_msg.sections.length > 0
                puts reply_msg.sections[0].doc
            else
                puts 'This message class does not have a .doc'
            end
        end

    end
end