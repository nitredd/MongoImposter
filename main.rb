require 'socket'
require 'bindata'
require 'bson'
require './msg_header'
require './msg_query'
require './msg_reply'
require './util_bstream_reader'
require './msg_parser'
require './server'
require './client'
require './relay'
require 'optparse'
require 'logger'
require './server_info'

def start_in_mode(cmdline_params)
    case cmdline_params[:mode]
    when 'server'
        s = cmdline_params.has_key?(:port) ? Server.new(cmdline_params[:port]) : Server.new
        s.start
    when 'client'
        c = cmdline_params.has_key?(:port) ? Client.new(cmdline_params[:port]) : Client.new
        c.start
    when 'relay'
        r = (cmdline_params.has_key?(:port) and cmdline_params.has_key?(:relay_host) and cmdline_params.has_key?(:relay_port)) ? Relay.new(cmdline_params[:port], cmdline_params[:relay_host], cmdline_params[:relay_port]) : Relay.new
        r.start
    when 'info'
        port_num = cmdline_params.has_key?(:port) ? cmdline_params[:port] : 27017
        hoat_name = cmdline_params.has_key?(:host) ? cmdline_params[:host] : 'localhost'
        si = ServerInfo.new(host: hoat_name, port: port_num)
        si.start
    else
        puts 'Invalid start mode. Start with: --mode {client|server}'
    end

    # for arg in ARGV
    #     if arg == 'server'
    #         s = Server.new
    #         s.start
    #     elsif arg == 'client'
    #         c = Client.new
    #         c.start
    #     end
    # end
end


def main
    cmdline_params = {}
    logmsg_arr = []

    OptionParser.new do |iter_cmdline|
        iter_cmdline.on('--mode STARTMODE', 'Startup as client or server') do |start_mode|
            cmdline_params[:mode] = start_mode
            logmsg_arr.append "CMDLINE: Starting WireProto in mode: #{start_mode}"
        end

        iter_cmdline.on('--host HOST', 'Host to connect to') do |host_name|
            cmdline_params[:host] = host_name
            logmsg_arr.append "CMDLINE: Setting host to: #{host_name}"
        end

        iter_cmdline.on('--port PORT', 'Port number to connect/listen') do |port_num|
            cmdline_params[:port] = port_num
            logmsg_arr.append "CMDLINE: Setting port number to : #{port_num}"
        end

        iter_cmdline.on('--relay_host HOST', 'Host to connect to') do |relay_host|
            cmdline_params[:relay_host] = relay_host
            logmsg_arr.append "CMDLINE: Setting relay host to: #{relay_host}"
        end

        iter_cmdline.on('--relay_port PORT', 'Port number to connect/listen') do |relay_port|
            cmdline_params[:relay_port] = relay_port
            logmsg_arr.append "CMDLINE: Setting relay port number to : #{relay_port}"
        end

        iter_cmdline.on('--logfile LOGFILE', 'Name of the log file') do |logfile|
            cmdline_params[:logfile] = logfile
            logmsg_arr.append "CMDLINE: Setting host to: #{logfile}"
        end
    end.parse!

    if cmdline_params.has_key?(:logfile)
        $logger = Logger.new(File.new(cmdline_params[:logfile], 'a'))
    else
        $logger = Logger.new STDOUT
    end

    logmsg_arr.each { |iter_msg| $logger.debug(iter_msg) }

    start_in_mode cmdline_params
end


#Invoke the main method
main


#require 'debug'