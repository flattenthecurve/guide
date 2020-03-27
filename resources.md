---
layout: page
title: Resources
permalink: /resources/
lang: en
order: 2
---

*This is a community maintained list of resources. We have done our best to provide guidelines to include only trusted sources, but these are NOT verified by out scientific team*

If you want to contribute to this list, you can do it [here](https://forms.gle/2zi67brmMZ7byCvb8)

<hr/>

{% assign current_country = "" %} 
{% assign resources = site.resources | sort: 'country' %}
{% for resource in resources %}
  {% if current_country != resource.country %}
    {% assign current_country = resource.country %}
   
    {% if current_country != nil %}
## {{ current_country }}
    {% else %}
## General
    {% endif %}
  {% endif %}

###  <a href="{{ resource.URL }}">{{ resource.name }}</a> 
  <p>{{ resource.content | markdownify }}</p>
  <hr/>
{% endfor %}