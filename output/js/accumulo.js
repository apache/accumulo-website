// Accumulo site-wide scripts for the default layout

// show location of canonical site if not currently on the canonical site
$(function() {
  var host = window.location.host;
  if (typeof host !== 'undefined' && host !== 'accumulo.apache.org') {
    $('#non-canonical').show();
  }
});

// decorate section headers with anchors
$(function() {
  return $("h2, h3, h4, h5, h6").not(".accordion-header").each(function(i, el) {
    var $el, icon, id;
    $el = $(el);
    id = $el.attr('id');
    icon = '<span class="fa-solid fa-link"></span>';
    if (id) {
      return $el.append($("<a />").addClass("header-link").attr("href", "#" + id).html(icon));
    }
  });
});

// fix sidebar width in documentation
$(function() {
  var $affixElement = $('div[data-spy="affix"]');
  $affixElement.width($affixElement.parent().width());
});

