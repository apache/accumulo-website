---
title: News Archive
permalink: /news/
redirect_from: /blog/
---

<div>
{% assign header_year = site.posts[0].date | date: "%Y" %}
<h3>{{header_year}}</h3>
{% for post in site.posts %}
  {% assign post_year = post.date | date: "%Y" %}
  {% if post_year != header_year %}
    {% assign header_year = post_year %}
    <hr>
    <h3>{{ header_year }}</h3>
  {% endif %}
  <div class="row" style="margin-top: 15px">
    <div class="col-md-1">{{ post.date | date: "%b %d" }}</div>
    <div class="col-md-10"><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></div>
  </div>
{% endfor %}
</div>
