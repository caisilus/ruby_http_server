# frozen_string_literal: true

require_relative 'lib/http_server'
require_relative 'lib/static_files_server'
require 'logger'

app = StaticFilesServer.new

logger = Logger.new($stdout)
logger.formatter = proc do |_sev, datetime, _prog, msg|
  "#{datetime.strftime('%d-%m-%Y %H:%M:%S')} || #{msg}\n"
end

server = HTTPServer.new(app, logger: logger, port: 5678)

def stop_server
  Thread.main[:keep_going] = false
  Thread.main[:threads].each(&:join)
end

def process_input
  s = gets
  return unless %w[exit q].include?(s.strip)

  stop_server
  exit 130
end

console_io_thread = Thread.new do
  loop do
    process_input
  end
end

server_thread = Thread.new do
  server.start
end

[console_io_thread, server_thread].each(&:join)
