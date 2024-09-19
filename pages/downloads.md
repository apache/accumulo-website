---
title: Downloads
permalink: /downloads/
---

<script type="text/javascript">

var updateLinks = function(mirror) {
  $('a[link-suffix]').each(function(i, obj) {
    $(obj).attr('href', mirror.replace(/\/+$/, "") + $(obj).attr('link-suffix'));
  });
};

var mirrorsCallback = function(json) {
  var htmlContent = '<div class="row align-items-center mb-3"><div class="col-3"><h5>Select an Apache download mirror:</h5></div>' +
    '<div class="col-5"><select class="form-select" id="apache-mirror-select">';
  htmlContent += '<optgroup label="Preferred Mirror (based on location)">';
  htmlContent += '<option selected="selected">' + json.preferred + '</option>';
  htmlContent += '</optgroup>';
  if (json.hasOwnProperty('http')) {
    htmlContent += '<optgroup label="HTTP Mirrors">';
    for (var i = 0; i < json.http.length; i++) {
      htmlContent += '<option>' + json.http[i] + '</option>';
    }
    htmlContent += '</optgroup>';
  }
  if (json.hasOwnProperty('ftp')) {
    htmlContent += '<optgroup label="FTP Mirrors">';
    for (var i = 0; i < json.ftp.length; i++) {
      htmlContent += '<option>' + json.ftp[i] + '</option>';
    }
    htmlContent += '</optgroup>';
  }
  if (json.hasOwnProperty('backup')) {
    htmlContent += '<optgroup label="Backup Mirrors">';
    for (var i = 0; i < json.backup.length; i++) {
      htmlContent += '<option>' + json.backup[i] + '</option>';
    }
    htmlContent += '</optgroup>';
  }
  htmlContent += '</select></div></div>';

  $("#mirror_selection").html(htmlContent);

  $( "#apache-mirror-select" ).change(function() {
    var mirror = $("#apache-mirror-select option:selected").text();
    updateLinks(mirror);
  });

  updateLinks(json.preferred);
};

// get mirrors when page is ready
$(function() { $.getJSON("https://accumulo.apache.org/mirrors.cgi?as_json", mirrorsCallback); });

</script>

<div id="mirror_selection"></div>

Be sure to [verify your downloads][VERIFY_PROCEDURES] using [these KEYS][GPG_KEYS].

{% assign closerLink = 'https://www.apache.org/dyn/closer.lua' %}
{% assign downloadsLink = 'https://downloads.apache.org' %}
{% assign glyphSave = '&nbsp;<span class="fa-solid fa-cloud-arrow-down"></span>' %}
{% assign glyphLock = '&nbsp;<span class="fa-solid fa-lock"></span>' %}
{% assign srcbinArray = 'src bin' | split: ' ' %}
{% assign btnDownloadStyle = 'class="btn btn-primary" style="text-transform: none; font-family: monospace"' %}
{% assign btnSigStyle = 'class="btn btn-outline-secondary" style="font-family: monospace"' %}
{% assign btnHashStyle = 'class="btn btn-outline-secondary" style="font-family: monospace"' %}
{% assign btnDocStyle = 'class="btn btn-secondary" style="text-transform: none; font-family: monospace; margin-bottom: 5px"' %}

## Current Releases

{% assign linkVers = '3.0.0' %}
### Accumulo {{linkVers}} **non-LTM**{: .badge .bg-warning}
{: #accumulo-nonltm }

The {{linkVers}} release of Apache Accumulo&reg; is the latest bleeding edge
release, containing the newest features, bug fixes, performance enhancements,
and more that are expected to appear in a future LTM release. The linked 2.x
documentation is still largely applicable to 3.x for now, except those items
that were removed from 3.x. Updated documention specific for 3.x will be made
available in a future update to this site.

{% for srcbin in srcbinArray %}
{% assign lnkFile = 'accumulo-' | append: linkVers | append: '-' | append: srcbin | append: '.tar.gz' %}
{% assign lnkSuffix = '/accumulo/' | append: linkVers | append: '/' | append: lnkFile %}
<div class="d-flex flex-wrap justify-content-start align-items-start" style="margin-left: 20px; margin-bottom: 5px;">
  <div class="btn-group me-2">
    <a {{btnDownloadStyle}} href="{{closerLink}}{{lnkSuffix}}" link-suffix="{{lnkSuffix}}">{{lnkFile}}{{glyphSave}}</a>
  </div>
  <div class="btn-group">
    <a {{btnSigStyle}} href="{{downloadsLink}}{{lnkSuffix}}.asc">ASC{{glyphLock}}</a>
    <a {{btnHashStyle}} href="{{downloadsLink}}{{lnkSuffix}}.sha512">SHA{{glyphLock}}</a>
  </div>
</div>
{% endfor %}
<div class="btn-group-sm" style="margin: 20px;">
  <a {{btnDocStyle}} href="{{site.baseurl}}/release/accumulo-{{linkVers}}">Release Notes</a>
  <a {{btnDocStyle}} href="https://github.com/apache/accumulo/blob/rel/{{linkVers}}/README.md">README</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/docs/2.x">Online Documentation</a>
  <a {{btnDocStyle}} href="https://github.com/apache/accumulo-examples">Examples</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/docs/2.x/apidocs3">Java API</a>
</div>


{% assign linkVers = '2.1.3' %}
### Accumulo {{linkVers}} **Latest**{: .badge .bg-primary} **LTM**{: .badge .bg-success}
{: #accumulo-latest-ltm }

The {{linkVers}} release of Apache Accumulo&reg; is the latest release on the
current stable generation, containing the newest bug fixes, performance
enhancements, and more.

{% for srcbin in srcbinArray %}
{% assign lnkFile = 'accumulo-' | append: linkVers | append: '-' | append: srcbin | append: '.tar.gz' %}
{% assign lnkSuffix = '/accumulo/' | append: linkVers | append: '/' | append: lnkFile %}
<div class="d-flex flex-wrap justify-content-start align-items-start" style="margin-left: 20px; margin-bottom: 5px;">
  <div class="btn-group me-2">
    <a {{btnDownloadStyle}} href="{{closerLink}}{{lnkSuffix}}" link-suffix="{{lnkSuffix}}">{{lnkFile}}{{glyphSave}}</a>
  </div>
  <div class="btn-group">
    <a {{btnSigStyle}} href="{{downloadsLink}}{{lnkSuffix}}.asc">ASC{{glyphLock}}</a>
    <a {{btnHashStyle}} href="{{downloadsLink}}{{lnkSuffix}}.sha512">SHA{{glyphLock}}</a>
  </div>
</div>
{% endfor %}
<div class="btn-group-sm" style="margin: 20px;">
  <a {{btnDocStyle}} href="{{site.baseurl}}/release/accumulo-{{linkVers}}">Release Notes</a>
  <a {{btnDocStyle}} href="https://github.com/apache/accumulo/blob/rel/{{linkVers}}/README.md">README</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/docs/2.x">Online Documentation</a>
  <a {{btnDocStyle}} href="https://github.com/apache/accumulo-examples">Examples</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/docs/2.x/apidocs">Java API</a>
</div>


{% assign linkVers = '1.0.0-beta' %}
### Accumulo Access {{linkVers}}
{: #accumulo-access }

The Accumulo Access library provides the same functionality, semantics, and syntax as the
Accumulo ColumnVisibility and VisibilityEvaluator classes in a standalone java library
that can be used separately from Accumulo.

{% assign lnkFile = 'accumulo-access-' | append: linkVers | append: '-' | append: 'source-release' | append: '.tar.gz' %}
{% assign lnkSuffix = '/accumulo/accumulo-access/' | append: linkVers | append: '/' | append: lnkFile %}
<div class="d-flex flex-wrap justify-content-start align-items-start" style="margin-left: 20px; margin-bottom: 5px;">
  <div class="btn-group me-2">
    <a {{btnDownloadStyle}} href="{{closerLink}}{{lnkSuffix}}" link-suffix="{{lnkSuffix}}">{{lnkFile}}{{glyphSave}}</a>
  </div>
  <div class="btn-group">
    <a {{btnSigStyle}} href="{{downloadsLink}}{{lnkSuffix}}.asc">ASC{{glyphLock}}</a>
    <a {{btnHashStyle}} href="{{downloadsLink}}{{lnkSuffix}}.sha512">SHA{{glyphLock}}</a>
  </div>
</div>

## <small><span class="fa-solid fa-circle-info" aria-hidden="true"></span></small> Legend
{: #legend }

**LTM**{: .badge .bg-success} / **non-LTM**{: .badge .bg-warning} indicates a [Long Term Maintenance][LTM] release or not

**Latest**{: .badge .bg-primary} / **Legacy**{: .badge .bg-secondary} indicates the latest or previous generation when two LTM releases are being concurrently maintained


## Older releases

Older releases are listed in the [release archive][ARCHIVE_REL] and can be
downloaded from the [download archive][ARCHIVE_DOWN].


[VERIFY_PROCEDURES]: https://www.apache.org/info/verification "Verify"
[GPG_KEYS]: https://downloads.apache.org/accumulo/KEYS "KEYS"
[ARCHIVE_DOWN]: https://archive.apache.org/dist/accumulo "Download Archive"
[ARCHIVE_REL]: {{site.baseurl}}/release/ "Release Archive"
[LTM]: {{site.baseurl}}/contributor/versioning.html#LTM "LTM Explained"
