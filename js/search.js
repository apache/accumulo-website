jQuery(function () {

  $.getJSON('/search_data.json').then(function (loaded_data) {

    window.idx = lunr(function () {
      this.field('id');
      this.field('title');
      this.field('content', { boost: 10 });
      this.field('categories');

      for (var index in loaded_data) {
        this.add($.extend({ "id": index }, loaded_data[index]));
      }
    });

    $("#site_search").submit(function (event) {
      event.preventDefault();
      var query = $("#search_box").val();
      var results = window.idx.search(query);
      display_search_results(query, results, loaded_data);
    });

  });

  function display_search_results(query, results, loaded_data) {
    var $search_status = $("#search_status");
    var $search_results = $("#search_results");

    if (!results.length) {
      $search_status.html('No results found!');
      return;
    }

    $search_status.html('Found ' + results.length + ' results for "' + query + '"');
    $search_results.empty();
    results.forEach(function (result) {
      var item = loaded_data[result.ref];
      var n = item.content.search(query) - 50
      if (n < 0) {
        n = 0;
      }
      var appendString = '<tr><td><a href="' + item.url + '">' + item.title + '</a><td>' + item.content.substring(n, n + 100) + '</tr>';
      $search_results.append(appendString);
    });

  }
});
