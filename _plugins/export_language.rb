require 'json'

Jekyll::Hooks.register :site, :post_write do |site|
  texts = {}

  site.data['sections']['en'].each do |file|
    key = key_from_filename(file)
    content = File.open(file, 'r:UTF-8') { |f| f.read }
    texts[key] = content
  end

  File.open("#{site.dest}/i18n-en.json", "w") do |file|
    file.puts JSON.pretty_generate(texts)
  end
end
