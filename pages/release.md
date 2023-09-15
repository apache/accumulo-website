---
title: Release Archive
permalink: /release/
redirect_from:
  - /release_notes/
  - /release_notes.html
---

{% assign archived_btn = '<a href="https://archive.apache.org/dist/accumulo/"><span class="badge bg-secondary">Archive</span></a>' %}
{% assign draft_btn = '<span class="badge bg-danger">&nbsp;DRAFT!&nbsp;</span>' %}
{% assign ltm_btn = '<a href="' | append: site.baseurl | append: '/contributor/versioning#LTM"><span class="badge bg-success">&nbsp;&nbsp;LTM&nbsp;&nbsp;</span></a>' %}
{% assign nonltm_btn = '<a href="' | append: site.baseurl | append: '/contributor/versioning#LTM"><span class="badge bg-warning">non-LTM</span></a>' %}

<div>
{% assign all_releases = site.categories.release | sort: 'date' | reverse %}
{% for release in all_releases %}
  {% assign current_release_year = release.date | date: "%Y" %}
  {% if forloop.first %}
    {% assign header_year = current_release_year %}
  <hr>
  <h3>{{ header_year }}</h3>
  {% elsif current_release_year != header_year %}
    {% assign header_year = current_release_year %}
  <hr>
  <h3>{{ header_year }}</h3>
  {% endif %}
  {% assign release_link = '&nbsp;<a href="' | append: site.baseurl | append: release.url | append: '">' | append: release.title | append: '</a>' %}
  {% if release.LTM %}{% assign ltm_or_not = ltm_btn %}{% else %}{% assign ltm_or_not = nonltm_btn %}{% endif %}
  <div class="row" style="margin-top: 15px; font-family: monospace">
    <div class="col-md-1">{{ release.date | date: "%b&nbsp;%d" }}</div>
    <div class="col-md-10">{% if release.draft %}
      {{ draft_btn }}&nbsp;{{ ltm_or_not }}<em><strong>{{ release_link }}</strong></em>
    {% elsif release.archived or release.archived_critical %}
      {{ archived_btn }}{{ release_link }}
    {% else %}
      {{ ltm_or_not }}<strong>{{ release_link }}</strong>
    {% endif %}</div>
  </div>
{% endfor %}
</div>

<hr>

Current releases can be [downloaded here][DOWNLOADS] and older releases can be
downloaded from the [download archive][ARCHIVE_DOWN].

[DOWNLOADS]: {{ site.baseurl }}/downloads/ "Current Downloads"
[ARCHIVE_DOWN]: https://archive.apache.org/dist/accumulo "Download Archive"
