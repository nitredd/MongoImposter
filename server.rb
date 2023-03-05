require './msg_query'
require './msg_writer'
require 'json'
require 'net/http'
require './server_handlers'

class Server
    def initialize(port=27017, bind_ip='0.0.0.0')
        @counter_request_id = 0
        @port = port
        @bind_ip = bind_ip  # Needed on Windows to bind to IPv4?
    end

    def start
        s = TCPServer.open(@bind_ip, @port)
        loop do
            c = s.accept
            Thread.new do
                # Needed for mongosh, but not the legacy shell - because mongosh establishes a connection pool
                loop do
                  req_msg = MessageParser.parse(c)
                  if req_msg == nil  #Typing exit on the mongo shell brings us here
                      puts 'Nil request message'  # 'Received nil op code. Disconnecting.'
                      break
                  end
                  puts 'Received request: '

                  # Display the document included in the message
                  if req_msg.class.method_defined? 'doc'
                      p req_msg.doc
                  else
                      if req_msg.class.method_defined? 'sections' and req_msg.sections.length > 0
                          puts req_msg.sections[0].doc
                      else
                        puts 'This message class does not have a .doc'
                      end
                  end

                  if req_msg.is_a?(QueryMessage)
                      std_header = StandardMessageHeader.new(op_code: OP_REPLY, response_to: req_msg.header.request_id, request_id: @counter_request_id)
                      @counter_request_id += 1

                      if req_msg.doc.has_key?(:isMaster) or req_msg.doc.has_key?(:ismaster) or req_msg.doc.has_key?(:hello)
                          doc = get_ismaster_doc
                      elsif req_msg.doc.has_key?(:whatsmyuri)
                          sock_domain, remote_port, remote_hostname, remote_ip = c.peeraddr
                          doc = BSON::Document.new(
                              you: "#{remote_ip}:#{remote_port}",
                              ok: 1
                          )
                      elsif req_msg.doc.has_key?(:buildinfo) or  req_msg.doc.has_key?(:buildInfo)
                          doc = get_buildinfo_doc
                      elsif req_msg.doc.has_key?(:getLog)
                          doc = BSON::Document.new(
                              totalLinesWritten: 1,
                              log: [
                                  "2020-06-21T20:49:03.498+0400 I  CONTROL  [initandlisten] ** WARNING: This is WireProto and not a real DB."
                              ],
                              ok: 1.0
                          )
                      elsif req_msg.doc.has_key?(:getFreeMonitoringStatus)
                          doc = BSON::Document.new(
                              state: "disabled",
                              message: "Free Monitoring support is not available in this build of MongoDB",
                              ok: 1.0
                          )
                      elsif req_msg.doc.has_key?(:getCmdLineOpts)
                          doc = BSON::Document.new(
                              argv: ["mongod", "--dbpath", "/Users/nitin/sandbox/010", "--port", "#{@port}"],
                              parsed: {
                                  net: {
                                      port: @port
                                  },
                                  storage: {
                                      dbPath: "/Users/nitin/sandbox/010"
                                  }
                              },
                              ok: 1.0
                          )
                      elsif req_msg.doc.has_key?(:replSetGetStatus)
                          doc = BSON::Document.new(
                              ok: 0.0,
                              errmsg: "not running with --replSet",
                              code: 76,
                              codeName: "NoReplicationEnabled"
                          )
                      elsif req_msg.doc.has_key?(:listDatabases)
                          doc = get_listdatabases_doc
                      elsif req_msg.doc.has_key?(:listCollections)
                          doc = get_listcollections_doc
                      # elsif not req_msg.collection_name.include? '$cmd'
                      #     msg = ''
                      #     random_option = rand(2)
                      #
                      #     case random_option
                      #     when 0
                      #         web_result = Net::HTTP.get(URI.parse('https://sv443.net/jokeapi/v2/joke/Any?blacklistFlags=nsfw,religious,racist,sexist&type=single'))
                      #         web_json = JSON.parse(web_result)
                      #         msg = web_json.has_key?('joke') ? web_json['joke'] : web_json['message']
                      #     when 1
                      #         web_result = Net::HTTP.get(URI.parse('https://api.chucknorris.io/jokes/random'))
                      #         web_json = JSON.parse(web_result)
                      #         msg = web_json['value']
                      #     else
                      #
                      #     end
                      #     doc = BSON::Document.new ({
                      #         'text': msg
                      #     })
                      #     #An empty object from BSON::Document.new() is different from how the server returns no results
                      else
                          puts 'Unrecognized query'
                          p req_msg.doc
                          break # TODO Handle this more elegantly
                      end

                      reply_msg = ReplyMessage.new(header: std_header, doc: doc)
                      MessageWriter.writeMessage(c, reply_msg)
                  elsif req_msg.is_a?(MessageMessage)
                      std_header = StandardMessageHeader.new(op_code: OP_MSG, response_to: req_msg.header.request_id, request_id: @counter_request_id)
                      @counter_request_id += 1

                      doc = nil
                      if req_msg.sections.length == 1
                          req_doc = req_msg.sections[0].doc
                          if req_doc.has_key?(:buildinfo) or req_msg.sections[0].doc.has_key?(:buildInfo)
                              doc = get_buildinfo_doc
                          elsif req_doc.has_key?(:getLog)
                              doc = get_getlog_doc
                          elsif req_doc.has_key?(:getFreeMonitoringStatus)
                              doc = get_freemonitoringstatus_doc
                          elsif req_doc.has_key?(:isMaster) or req_msg.sections[0].doc.has_key?(:ismaster) or req_msg.sections[0].doc.has_key?(:hello)
                              doc = get_ismaster_doc
                          elsif req_doc.has_key?(:replSetGetStatus)
                              doc = BSON::Document.new(
                                errmsg: "not running with --replSet",
                                code: 76,
                                codeName: "NoReplicationEnabled",
                                ok: 0
                              )
                          elsif req_doc.has_key?(:getCmdLineOpts)
                              doc = BSON::Document.new(
                                argv: [],
                                parsed: {},
                                ok: 1,
                                "$clusterTime": {
                                  clusterTime: BSON::Timestamp.new(Time.now.to_i, 0), #Time.now
                                  signature: {
                                    hash: "\0\0\0\0",  #TODO How is this hash generated?
                                    keyId: 6838625487661563906  #TODO How is this keyId generated?
                                  }
                                },
                                operationTime: Time.now
                              )
                          elsif req_doc.has_key?(:atlasVersion)
                              doc = BSON::Document.new(
                                errmsg: "no such command: 'atlasVersion'",
                                code: 59,
                                codeName: "CommandNotFound",
                                ok: 0,
                                "$clusterTime": {
                                  clusterTime: BSON::Timestamp.new(Time.now.to_i, 0), #Time.now
                                  signature: {
                                    hash: "\0\0\0\0",  #TODO How is this hash generated?
                                    keyId: 6838625487661563906  #TODO How is this keyId generated?
                                  }
                                },
                                operationTime: Time.now
                              )
                          elsif req_doc.has_key?(:getParameter)
                              doc = get_getparameter_doc
                          elsif req_doc.has_key?(:ping)
                              doc = get_ping_doc
                          elsif req_doc.has_key?(:connectionStatus)
                              doc = get_connectionstatus_doc
                          elsif req_doc.has_key?(:listDatabases)
                              doc = get_listdatabases_doc
                          elsif req_doc.has_key?(:listCollections)
                              doc = get_listcollections_doc
                          elsif req_doc.has_key?(:dbStats)
                              doc = get_dbstats_doc
                          elsif req_doc.has_key?(:find)
                              doc = get_find_doc(req_doc)
                          elsif req_doc.has_key?(:hostInfo)
                              doc = get_hostinfo_doc
                          end
                      end

                      if doc.nil?
                          doc = get_ismaster_doc
                      end

                      section = MessageMessageSection.new(doc: doc)
                      msg_msg = MessageMessage.new(header: std_header)
                      msg_msg.sections.append section

                      MessageWriter.writeMessage(c, msg_msg)
                  else
                      puts 'Unrecognized message type'
                      p req_msg
                      break  # TODO Handle this more elegantly
                  end
                end
                c.close
            end
        end
        s.close        
    end
end

###
# Raw: {"length":300,"requestId":0,"responseTo":0,"opCode":2004,"flags":0,"fullCollectionName":"admin.$cmd","numberToSkip":0,"numberToReturn":1,"query":{"isMaster":1,"hostInfo":"Nitins-MBP:27017","client":{"application":{"name":"MongoDB Shell"},"driver":{"name":"MongoDB Internal Client","version":"4.2.2"},"os":{"type":"Darwin","name":"Mac OS X","architecture":"x86_64","version":"19.5.0"}}}}
###
# Raw: {"length":60,"requestId":1,"responseTo":0,"opCode":2004,"flags":0,"fullCollectionName":"admin.$cmd","numberToSkip":0,"numberToReturn":1,"query":{"whatsmyuri":1}}
###
# #<QueryMessage:0x00007f9e409335b0 @header=#<StandardMessageHeader:0x00007f9e40933e20 @message_length=63, @request_id=2, @response_to=0, @op_code=2004, @placeholder=nil>, @flags=0, @collection_name="admin.$cmd", @num_skip=0, @num_return=1,
# @query_doc={"buildinfo"=>1.0}, @field_selector=nil>
###
