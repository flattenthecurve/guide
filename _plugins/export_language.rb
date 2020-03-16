require 'json'

texts = {}

Jekyll::Hooks.register :site, :pre_render do |site|
  texts = {}
end

Jekyll::Hooks.register :pages, :post_init do |page|
  if key = key_from_page_filename(page.name)
    texts[key] = page.content
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  next unless site.config['active_lang'] == 'en'
  texts.merge!(site.data['strings'])

  site.data['sections']['en'].each do |file|
    key = key_from_filename(file)
    content = File.open(file, 'r:UTF-8') { |f| f.read }
    texts[key] = content
  end

  File.open("#{site.dest}/i18n-en.json", "w") do |file|
    file.puts JSON.pretty_generate(texts)
  end
end
