---
title: Accumulo Tour
layout: page
permalink: /tour-jshell/
skiph1fortitle: true
---

{% assign tour_pages = site.data.tour-jshell.docs %}
{% assign first_url = tour_pages[0] | prepend: '/tour-jshell/' | append: '/' %}
{% assign first_page = site.pages | where:'url',first_url | first %}

Welcome to the JShell version of the Accumulo tour! When on a tour page, the left and
right keys on the keyboard can be used to navigate. The tour begins at the
[{{ first_page.title }}]({{ first_url }}) page.

If you have any questions or suggestions while
going through the tour, please email our [mailing list][mlist] or [create an issue][issue].

{% for p in tour_pages %}
  {% assign doc_url = p | prepend: '/tour-jshell/' | append: '/' %}
  {% assign link_to_page = site.pages | where:'url',doc_url | first %}
  1. [{{ link_to_page.title }}]({{ doc_url }})
{% endfor %}

[mlist]: /contact-us/#mailing-lists
[issue]: https://github.com/apache/accumulo-website/issues
