require 'json'

def key_from_filename(name)
  basename = File.basename(name)
  if basename =~ /\d\d-(.*)\.md/
      return $1
  else
      raise "#{basename} doesn't match the \"99-some-file-name.md\" name format (in #{name})"
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  texts = {}

  site.data['sections'].each do |file|
    key = key_from_filename(file)
    content = File.open(file, 'r:UTF-8') { |f| f.read }
    texts[key] = content
  end

  File.open("#{site.dest}/i18n-en.json", "w") do |file|
    file.puts JSON.pretty_generate(texts)
  end
end

