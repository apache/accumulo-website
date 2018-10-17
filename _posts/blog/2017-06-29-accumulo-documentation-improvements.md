---
title: "Documentation Improvements for 2.0"
author: Mike Walch
---

Since Accumulo 1.7, the [Accumulo user manual][manual] source resided in the [source repository][accumulo-repo] as asciidoc. For every release or update to the manual,
an HTML document is produced from the asciidoc, committed to the [project website repository][website-repo], and published to the website. This process will remain
for 1.x releases.

For 2.0, the source for the user manual was converted to markdown and moved to the [website repository][website-repo]. The
[upcoming 2.0 documentation][docs-2.0] has several improvements over the older documentation:

* Improved navigation using a new sidebar
* Changes to the documentation are now immediately viewable on the website
* Better linking to Javadocs and between documentation pages
* Documentation style now matches the website

While the [2.0 documentation][docs-2.0] is viewable, it is not linked to (except by this post) and every page contains a warning that the documentation
is for a future release. Each page also links to the documentation for the latest release.

It is now much easier to view, edit, and propose changes to the documentation. If you would like to contribute to the documentation for 2.0, view
the [documentation][docs-2.0]. Each page has an **Edit this page** link that will take you to GitHub where you can edit the markdown for the page, preview it,
and submit a pull request to the [website repository][website-repo]. A committer will review your changes so don't be afraid to contribute!

[manual]: /1.8/accumulo_user_manual.html
[accumulo-repo]: https://github.com/apache/accumulo
[website-repo]: https://github.com/apache/accumulo-website
[docs-2.0]: /docs/2.x/
