---
title: Accumulo Tour
layout: page
permalink: /tour/
skiph1fortitle: true
---

{% assign tour_pages = site.data.tour.docs %}
{% assign first_url = tour_pages[0] | prepend: '/tour/' | append: '/' %}
{% assign first_page = site.pages | where:'url',first_url | first %}

Welcome to the Accumulo tour! The tour offers a hands on introduction to Accumulo, broken down into
independent steps and an exercise. The exercise gives you a chance to apply what you have learned.
The tour starts with a [{{ first_page.title }}]({{ first_url }}) page that will help you set up
the exercise on your machine.

We recommend following the tour in order. However, all pages are listed below for review.  When on a
tour page, the left and right keys on the keyboard can be used to navigate. If you have any questions
or suggestions while going through the tour, please send an email to our [mailing list][mlist]
or [create an issue][issue].

{% for p in tour_pages %}
  {% assign doc_url = p | prepend: '/tour/' | append: '/' %}
  {% assign link_to_page = site.pages | where:'url',doc_url | first %}
  1. [{{ link_to_page.title }}]({{ doc_url }})
{% endfor %}

[mlist]: /mailing_list/
[issue]: https://issues.apache.org/jira/projects/ACCUMULO
