jQuery(function() {

  window.idx = lunr(function () {
    this.field('id');
    this.field('title');
    this.field('content', { boost: 10 });
    this.field('categories');
  });

  window.data = $.getJSON('/search_data.json');

  window.data.then(function(loaded_data){
    $.each(loaded_data, function(index, value){
      window.idx.add($.extend({ "id": index }, value));
    });
  });

  $("#site_search").submit(function(event){
      event.preventDefault();
      var query = $("#search_box").val();
      var results = window.idx.search(query);
      display_search_results(query, results);
  });

  function display_search_results(query, results) {
    var $search_status = $("#search_status");
    var $search_results = $("#search_results");

    window.data.then(function(loaded_data) {

      if (results.length) {
        $search_status.html('Found ' + results.length + ' results for "' + query + '"');
        $search_results.empty();
        results.forEach(function(result) {
          var item = loaded_data[result.ref];
          var n = item.content.search(query) - 50
          if (n < 0) {
            n = 0;
          }
          var appendString = '<tr><td><a href="' + item.url + '">' + item.title + '</a><td>' + item.content.substring(n, n+100) + '</tr>';
          $search_results.append(appendString);
        });
      } else {
        $search_status.html('No results found!');
      }
    });
  }
});
