class Dir
  def filenames(recursive: false)
    children.map do |entry|
      entry_fullpath = File.join(path, entry)

      filenames_for_entry(entry_fullpath, recursive)
    end.flatten
  end

  private

  def filenames_for_entry(entry, recursive)
    filenames = []

    return [entry] if File.file?(entry)

    return unless recursive && File.directory?(entry)

    names_in_subdir = Dir.new(entry).filenames(recursive: true)

    filenames.push(*names_in_subdir)
  end
end
