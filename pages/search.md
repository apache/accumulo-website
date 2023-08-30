---
title: Search
permalink: /search/
---

Search results are limited to blog posts, release notes, and the 2.x documentation.

<div class="row">
  <div class="col-lg-6">
    <form action="get" id="site_search">
      <div class="input-group">
        <input class="form-control" type="text" id="search_box" placeholder="Search for...">
        <button class="btn btn-secondary" type="submit">Search</button>
      </div>
    </form>
  </div>
</div>

<br/>

<div id="search_status"></div>

<table class="table table-striped"><tbody id="search_results"></tbody></table>

<script src="https://unpkg.com/lunr@2.3.9/lunr.min.js"></script>
<script src="/js/search.js"></script>
