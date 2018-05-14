---
title: Release Archive
permalink: /release/
redirect_from: 
  - /release_notes/
  - /release_notes.html
---

<div>
<hr>

{% assign visible_releases = site.categories.release | where:"draft",false %}
{% assign header_year = visible_releases[0].date | date: "%Y" %}
<h3>{{header_year}}</h3>
{% for release in visible_releases %}
  {% assign current_release_year = release.date | date: "%Y" %}
  {% if current_release_year != header_year %}
    {% assign header_year = current_release_year %}
    <hr>
    <h3>{{ header_year }}</h3>
  {% endif %}
  <div class="row" style="margin-top: 15px">
    <div class="col-md-1">{{ release.date | date: "%b %d" }}</div>
    {% if release.archived or release.archived_critical %}
      <div class="col-md-10"><a href="{{ site.baseurl }}{{ release.url }}">{{ release.title }}</a></div>
    {% else %}
      <div class="col-md-10"><strong><a href="{{ site.baseurl }}{{ release.url }}">{{ release.title }}</a>&nbsp;&lArr;&nbsp;current</strong></div>
    {% endif %}
  </div>
{% endfor %}
</div>

<hr>

Current releases can be [downloaded here][DOWNLOADS] and older releases can be
downloaded from the [download archive][ARCHIVE_DOWN].

[DOWNLOADS]: {{ site.baseurl }}/downloads/ "Current Downloads"
[ARCHIVE_DOWN]: https://archive.apache.org/dist/accumulo "Download Archive"
