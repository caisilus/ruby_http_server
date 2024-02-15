class HTTPRequest
  attr_reader :headers, :body, :method, :path, :protocol

  def initialize(tcp_socket, body_delimeter_regex: /\A[ \n\r\t]+\z/)
    @body_delimeter_regex = body_delimeter_regex

    @method, @path, @protocol = tcp_socket.gets.split

    @headers = {}
    read_headers(tcp_socket, body_delimeter_regex)

    @body = tcp_socket.read(@headers['Content-Length'].to_i)
  end

  private

  def read_headers(tcp_socket)
    line = tcp_socket.gets

    until body_delimeter?(line)
      key, value = line.split(': ')
      @headers[key] = value

      line = tcp_socket.gets
    end
  end

  def body_delimeter?(line)
    !!line.match(@body_delimeter_regex)
  end
end
