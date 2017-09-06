---
title: News Archive
permalink: /news/
redirect_from: /blog/
---

<div>
{% assign visible_posts = site.posts | where:"draft",false %}
{% assign header_year = visible_posts[0].date | date: "%Y" %}
<h3>{{header_year}}</h3>
{% for post in visible_posts %}
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
