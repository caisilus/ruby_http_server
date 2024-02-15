require_relative './files_content_types'
require 'cgi'

class StaticFilesServer
  include FilesContentTypes

  def initialize(serving_dir_path: 'serve')
    @dir_path = serving_dir_path
    @filenames = files_in_dir(@dir_path)
  end

  def files_in_dir(dir_path, recursive: true)
    filenames = []
    Dir.new(dir_path).each_child do |entrie|
      full_entrie_name = File.join(dir_path, entrie)

      filenames << full_entrie_name if File.file?(full_entrie_name)

      next unless recursive && !File.file?(full_entrie_name)

      names_in_subdir = files_in_dir(full_entrie_name)

      filenames.push(*names_in_subdir)
    end

    filenames
  end

  def serve(request, root: 'index.html')
    filename = request.path.slice(1..-1) # without /
    filename = CGI.unescape(filename)
    filename = root if filename.empty?
    filename = File.join(@dir_path, filename)

    return not_found unless @filenames.include?(filename)

    ok(filename)
  end

  private

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
