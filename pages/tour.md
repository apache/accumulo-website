---
title: Accumulo Tour
layout: page
permalink: /accumulo-tour/
skiph1fortitle: true
---

{% assign tour_pages = site.data.tour.docs %}
{% assign first_url = tour_pages[0] | prepend: '/tour/' | append: '/' %}
{% assign first_page = site.pages | where:'url',first_url | first %}

{% assign jshell_pages = site.data.tour-jshell.docs %}
{% assign first_jshell_url = tour_pages[0] | prepend: '/tour-jshell/' | append: '/' %}
{% assign first_jshell_page = site.pages | where:'url',first_jshell_url | first %}

Welcome to the Accumulo tour! The tour offers a hands-on introduction to the [Accumulo Java API](/api),
broken down into independent steps and exercises. The exercises give you a chance to apply what you have
learned by writing code on your own. The answers to an exercise are typically provided in the next step.

There are two options for using the tour. The first utilizes Accumulo's MiniAccumuloCluster and 
standard Java class development to progress through the tour. The second uses the newer Accumulo
JShell feature, introduced in version 2.1.0, to complete the tour.

The MiniAccumuloCluster version can be found [here][mac-tour]. If using Accumulo 2.0.x, this is the 
version that must be followed.

The JShell version begins [here][jshell-tour]. This version is available for version 2.1.x or greater. 


* [**MiniAccumuloCluster Tour**][mac-tour]
* [**JShell Tour**][jshell-tour]


[mlist]: /contact-us/#mailing-lists
[issue]: https://github.com/apache/accumulo-website/issues
[mac-tour]: /tour/
[jshell-tour]: /tour-jshell/
