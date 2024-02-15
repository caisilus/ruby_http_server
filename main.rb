# frozen_string_literal: true

require_relative 'lib/http_server'
require_relative 'lib/static_files_server'

app = StaticFilesServer.new
server = HTTPServer.new(app)

server.start
