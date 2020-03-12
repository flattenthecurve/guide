---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---

{% for item in site.data.sections %}
  {% capture my_include %}{% include_relative {{ item }} %}{% endcapture %}
  {{ my_include | markdownify }}
{% endfor %}
