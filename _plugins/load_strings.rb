Jekyll::Hooks.register :site, :pre_render do |site|
  site.config['title'] = site.data['strings']['title']
  site.config['description'] = site.data['strings']['description']
end
