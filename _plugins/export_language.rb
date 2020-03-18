require 'json'

texts = {}

Jekyll::Hooks.register :site, :after_reset do |site|
  texts = {}
end

Jekyll::Hooks.register :pages, :post_init do |page|
  if key = key_from_page_filename(page.name)
    texts[key] = page.content unless page.data['translate_content'] == false
    texts["#{key}-title"] = page.data['title']
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  next unless site.config['active_lang'] == 'en'
  texts.merge!(site.data['strings'])
  texts.merge!(site.data['section_content'] || {})

  File.write "#{site.dest}/i18n-en.json", JSON.pretty_generate(texts)
end
