require './msg_query'
require './msg_writer'
require 'json'
require 'net/http'

class Relay
  def initialize(port=27017, relay_host='127.0.0.1', relay_port=27017)
    @counter_request_id = 0
    @port = port
    @relay_host = relay_host
    @relay_port = relay_port
  end


  def start
    s = TCPServer.open(@port)
    c = s.accept

    r = TCPSocket.open(@relay_host, @relay_port)

    loop do
      req_msg = MessageParser.parse(c)
      if req_msg == nil
        break
      end
      MessageWriter.writeMessage(r, req_msg)
      resp_msg = MessageParser.parse(r)
      MessageWriter.writeMessage(c, resp_msg)
    end

    r.close
    c.close
    s.close
  end
end
