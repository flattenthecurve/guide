---
layout: page
title: Resources
permalink: /resources/
lang: en
order: 2
---

*This is a community maintained list of resources. We have done our best to provide guidelines to include only trusted sources, that is NOT verified by out scientific team*

<hr>
<ul>
{% for resource in site.resources %}
  <a href="{{ resource.URL }}">{{ resource.name }}</a>: 
  <p>{{ resource.content | markdownify }}</p>
  <hr>
{% endfor %}
<ul>