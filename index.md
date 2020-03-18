---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
translate_content: false
---

{% for item in site.data.home_sections[site.active_lang] %}
  {% capture my_include %}{% include_relative {{ item }} %}{% endcapture %}
  {{ my_include | markdownify }}
{% endfor %}
