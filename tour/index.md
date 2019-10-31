---
title: Accumulo Tour
layout: page
permalink: /tour/
skiph1fortitle: true
---

{% assign tour_pages = site.data.tour.docs %}
{% assign first_url = tour_pages[0] | prepend: '/tour/' | append: '/' %}
{% assign first_page = site.pages | where:'url',first_url | first %}

Welcome to the Accumulo tour! The tour offers a hands on introduction to the [Accumulo Java API](/api), broken down into
independent steps and exercises. The exercises give you a chance to apply what you have learned by writing code on your
own. The answers to an exercise are typically provided in the next step.  The tour begins at the
[{{ first_page.title }}]({{ first_url }}) page.

When on a tour page, the left and right keys on the keyboard can be used to navigate. If you have any questions
or suggestions while going through the tour, please send an email to our [mailing list][mlist]
or [create an issue][issue].

{% for p in tour_pages %}
  {% assign doc_url = p | prepend: '/tour/' | append: '/' %}
  {% assign link_to_page = site.pages | where:'url',doc_url | first %}
  1. [{{ link_to_page.title }}]({{ doc_url }})
{% endfor %}

[mlist]: /contact-us/#mailing-lists
[issue]: https://github.com/apache/accumulo-website/issues
