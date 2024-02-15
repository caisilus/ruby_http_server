# frozen_string_literal: true

require 'socket'
# require_relative 'lib/logger'
require_relative './http_request'
require_relative './static_files_server'

class HTTPServer
  def initialize(app, port: 5678)
    @tcp_server = TCPServer.new port
    @app = app
  end

  def start
    while (tcp_socket = @tcp_server.accept)
      request = HTTPRequest.new(tcp_socket)
      puts "METHOD: #{request.method}, PATH: #{request.path}, PROTO: #{request.protocol}"

      response = @app.serve(request)

      write_response(tcp_socket, response)
    end
  end

  private

  def write_response(tcp_socket, app_response)
    status, headers, body = app_response

    tcp_socket.print "HTTP/1.1 #{status}\r\n"

    write_headers(tcp_socket, headers)

    tcp_socket.print "\r\n"

    write_body(tcp_socket, body)

    tcp_socket.close
  end

  def write_headers(tcp_socket, headers)
    headers.each do |key, value|
      tcp_socket.print "#{key}: #{value}\r\n"
    end
  end

  def write_body(tcp_socket, body)
    body.each do |part|
      tcp_socket.print part
    end
  end
end
