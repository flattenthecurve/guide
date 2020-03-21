---
layout: page
title: Resources
permalink: /resources/
lang: en
order: 2
---

*This is a community maintained list of resources. We have done our best to provide guidelines to include only trusted sources, that is NOT verified by out scientific team*

<hr/>
{% assign current_country = "" %}
{% for resource in site.resources %}
  {% if current_country != resource.country %}
    <h2>{{ resource.country }}</h2>
    {% assign current_country = resource.country %}

  {% endif %}

  <a href="{{ resource.URL }}">{{ resource.name }}</a>: 
  <p>{{ resource.content | markdownify }}</p>
  <hr/>
{% endfor %}