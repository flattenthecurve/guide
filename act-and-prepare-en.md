---
layout: page_with_toc
title: Act & Prepare
permalink: /act-and-prepare/
lang: en
order: 1
---

{% for item in site.data.act_and_prepare[site.active_lang] %}
  {% capture my_include %}{% include_relative {{ item }} %}{% endcapture %}
  {{ my_include | markdownify }}
{% endfor %}

