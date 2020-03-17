---
layout: page
---

<ul id="lang-bar">
{% for tongue in site.languages %}
<li><a {% if tongue == site.active_lang %}style="font-weight: bold;"{% endif %} href="{% if tongue == site.default_lang %} {{site.baseurl}}{{page.url}} {% else %} {{site.baseurl}}/{{ tongue }}{{page.url}} {% endif %}">{{ site.data.lang_name[tongue] }}</a></li>{% endfor %}
</ul>

{% for item in site.data.sections[site.active_lang] %}
  {% capture my_include %}{% include_relative {{ item }} %}{% endcapture %}
  {{ my_include | markdownify }}
{% endfor %}
