module FilesContentTypes
  EXTENTIONS_TO_CONTENT_TYPES = {
    'css': 'text/css',
    'html': 'text/html',
    'js': 'application/javascript',
    'png': 'image/png'
  }.freeze

  def file_content_type(filename)
    ext = filename.split('.').last

    EXTENTIONS_TO_CONTENT_TYPES[ext]
  end
end
