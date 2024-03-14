# frozen_string_literal: true

require 'socket'
require 'logger'
require_relative './http_request'
require_relative './static_files_server'

class HTTPServer
  def initialize(app, logger: Logger.new($stdout), port: 5678)
    @tcp_server = TCPServer.new port
    @app = app
    @logger = logger

    Thread.main[:threads] = []
  end

  def start
    Thread.main[:keep_going] = true

    while keep_going?
      puts 'loop step'
      Thread.main[:threads] << request_thread
    end
  end

  private

  def keep_going?
    Thread.main[:keep_going]
  end

  def request_thread
    Thread.new(@tcp_server.accept) do |tcp_socket|
      client_ip = tcp_socket.peeraddr[3]

      request = HTTPRequest.new(tcp_socket)

      @logger.info("METHOD: request.method; PATH: #{request.path}")

      response = @app.serve(request)

      write_response(tcp_socket, response)

      @logger.info("IP: #{client_ip}; PATH: #{request.path}; ANSWER: #{response.first}")
    end
  end

  def write_response(tcp_socket, response)
    status, headers, body = response

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
