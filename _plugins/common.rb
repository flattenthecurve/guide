def key_from_filename(name)
  basename = File.basename(name)
  if basename =~ /\d\d-(.*)\.md/
      return $1
  else
      raise "#{basename} doesn't match the \"99-some-file-name.md\" name format (in #{name})"
  end
end

def key_from_page_filename(name)
  if name =~ /(.*)-en.md/
    return $1
  end
end
