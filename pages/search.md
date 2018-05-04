---
title: Search
permalink: /search/
---

Search results are limited to blog posts, release notes, and the 2.0 documentation.

<div class="row">
  <div class="col-lg-6">
    <form action="get" id="site_search">
      <div class="input-group">
        <input class="form-control" type="text" id="search_box" placeholder="Search for...">
        <span class="input-group-btn">
          <button class="btn btn-default" type="submit">Search</button>
        </span>
      </div>
    </form>
  </div>
</div>

<br/>

<div id="search_status"></div>

<table class="table table-striped" id="search_results"></table>

<script src="https://cdnjs.cloudflare.com/ajax/libs/lunr.js/1.0.0/lunr.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="/js/search.js"></script>
