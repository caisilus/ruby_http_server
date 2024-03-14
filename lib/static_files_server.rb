# frozen_string_literal: true

require_relative './files_content_types'
require_relative './dir_patch'
require 'cgi'

class StaticFilesServer
  include FilesContentTypes

  def initialize(serving_dir_path: 'static')
    @dir_path = serving_dir_path
    @filenames = Dir.new(@dir_path).filenames(recursive: true)
  end

  def serve(request, root: 'index.html')
    sleep 2

    filename = filename_for_http_path(request.path, root: root)

    return not_found unless @filenames.include?(filename)

    ok(filename)
  end

  private

  def filename_for_http_path(path, root: 'index.html')
    filename = path.slice(1..-1) # without starting '/'
    filename = CGI.unescape(filename)
    filename = root if filename.empty?

    File.join(@dir_path, filename)
  end

  def not_found
    answer_code = '404'
    headers = { "Content-Type": 'text/html' }
    body = ['No such file']

    [answer_code, headers, body]
  end

  def ok(filename)
    answer_code = '200'
    headers = { "Content-Type": file_content_type(filename) }
    body = File.readlines(filename)

    [answer_code, headers, body]
  end
end
