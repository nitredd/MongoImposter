require 'mongo'

class ServerInfo
  def initialize(host: 'localhost', port: 27017, db: 'test')
    @host = host
    @port = port
    @db = db
  end
  def start
    client = Mongo::Client.new([ "#{@host}:#{@port}" ], :database => @db)
    puts client.inspect
    client.close
  end
end