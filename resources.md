---
layout: page
title: Resources
permalink: /resources/
lang: en
order: 2
---

{% for resource in site.resources %}
  <a href="{{ resource.URL }}">{{ resource.name }}</a>
  <p>{{ resource.content | markdownify }}</p>
{% endfor %}
