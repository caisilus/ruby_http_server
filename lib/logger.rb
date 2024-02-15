class Logger
  def initialize(file_path)
    @file_path = file_path
  end

  def log(message)
    open(@file_path, "a") do |file|
      file.puts(message)
    end
  end
end
