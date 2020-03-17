---
layout: home
title: Act & Prepare
permalink: /act-and-prepare/
lang: en
order: 1
---

{% for item in site.act-and-prepare[site.active_lang] %}
  {{ item.content | markdownify }}
{% endfor %}

