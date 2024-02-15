# frozen_string_literal: true

require_relative 'lib/http_server'
require_relative 'lib/static_files_server'
require 'logger'

app = StaticFilesServer.new

logger = Logger.new($stdout)
logger.formatter = proc do |_sev, datetime, _prog, msg|
  "#{datetime.strftime('%d-%m-%Y %H:%M:%S')} || #{msg}\n"
end

server = HTTPServer.new(app, logger: logger)

server.start
