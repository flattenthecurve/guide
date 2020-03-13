---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---
{% for tongue in site.languages %}
<a {% if tongue == site.active_lang %}style="font-weight: bold;"{% endif %} href="{% if tongue == site.default_lang %} {{site.baseurl}}{{page.url}} {% else %} {{site.baseurl}}/{{ tongue }}{{page.url}} {% endif %}">{{ tongue }}</a>{% endfor %}

{% for item in site.data.sections[site.active_lang] %}
  {% capture my_include %}{% include_relative {{ item }} %}{% endcapture %}
  {{ my_include | markdownify }}
{% endfor %}
