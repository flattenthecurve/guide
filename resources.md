---
layout: page
---

<ul id="lang-bar">
{% for tongue in site.languages %}
<li><a {% if tongue == site.active_lang %}style="font-weight: bold;"{% endif %} href="{% if tongue == site.default_lang %} {{site.baseurl}}{{page.url}} {% else %} {{site.baseurl}}/{{ tongue }}{{page.url}} {% endif %}">{{ site.data.lang_name[tongue] }}</a></li>{% endfor %}
</ul>

{% for resource in site.resources[site.active_lang] %}
  {{ resource.content | markdownify }}
{% endfor %}
