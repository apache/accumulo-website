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
  var htmlContent = '<div class="row"><div class="col-md-3"><h5>Select an Apache download mirror:</h5></div>' +
    '<div class="col-md-5"><select class="form-control" id="apache-mirror-select">';
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
{% assign glyphSave = '&nbsp;<span class="glyphicon glyphicon-cloud-download"></span>' %}
{% assign glyphLock = '&nbsp;<span class="glyphicon glyphicon-lock"></span>' %}
{% assign srcbinArray = 'src bin' | split: ' ' %}
{% assign btnDownloadStyle = 'class="btn btn-primary" style="text-transform: none; font-family: monospace"' %}
{% assign btnSigStyle = 'class="btn btn-default" style="font-family: monospace"' %}
{% assign btnHashStyle = 'class="btn btn-default" style="font-family: monospace"' %}
{% assign btnDocStyle = 'class="btn btn-default" style="text-transform: none; font-family: monospace; margin-bottom: 5px"' %}

## Current Releases

{% assign linkVers = '2.1.0' %}
### {{linkVers}} **Latest**{: .label .label-primary} **LTM**{: .label .label-success}
{: #latest }

The {{linkVers}} release of Apache Accumulo&reg; is the latest release on the
current generation, containing the newest features, bug fixes, performance
enhancements, and more.

{% for srcbin in srcbinArray %}
{% assign lnkFile = 'accumulo-' | append: linkVers | append: '-' | append: srcbin | append: '.tar.gz' %}
{% assign lnkSuffix = '/accumulo/' | append: linkVers | append: '/' | append: lnkFile %}
<div class="row btn-group" style="margin-left: 20px; margin-bottom: 5px; display: block">
  <div class="col btn-group">
    <a {{btnDownloadStyle}} href="{{closerLink}}{{lnkSuffix}}" link-suffix="{{lnkSuffix}}">{{lnkFile}}{{glyphSave}}</a>
  </div><div class="col btn-group">
    <a {{btnSigStyle}} href="{{downloadsLink}}{{lnkSuffix}}.asc">ASC{{glyphLock}}</a>
    <a {{btnHashStyle}} href="{{downloadsLink}}{{lnkSuffix}}.sha512">SHA{{glyphLock}}</a>
  </div>
</div>
{% endfor %}
<div class="row btn-group-sm" style="margin: 20px">
  <a {{btnDocStyle}} href="{{site.baseurl}}/release/accumulo-{{linkVers}}">Release Notes</a>
  <a {{btnDocStyle}} href="https://github.com/apache/accumulo/blob/rel/{{linkVers}}/README.md">README</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/docs/2.x">Online Documentation</a>
  <a {{btnDocStyle}} href="https://github.com/apache/accumulo-examples">Examples</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/docs/2.x/apidocs">Java API</a>
</div>


{% assign linkVers = '1.10.3' %}
### {{linkVers}} **Legacy**{: .label .label-default} **LTM**{: .label .label-success}
{: #legacy }

The most recent legacy (1.x) release of Apache Accumulo&reg; is version
{{linkVers}}.

The 1.10 release series will reach end-of-life on **November 1, 2023**.

{% for srcbin in srcbinArray %}
{% assign lnkFile = 'accumulo-' | append: linkVers | append: '-' | append: srcbin | append: '.tar.gz' %}
{% assign lnkSuffix = '/accumulo/' | append: linkVers | append: '/' | append: lnkFile %}
<div class="row btn-group" style="margin-left: 20px; margin-bottom: 5px; display: block">
  <div class="col btn-group">
    <a {{btnDownloadStyle}} href="{{closerLink}}{{lnkSuffix}}" link-suffix="{{lnkSuffix}}">{{lnkFile}}{{glyphSave}}</a>
  </div><div class="col btn-group">
    <a {{btnSigStyle}} href="{{downloadsLink}}{{lnkSuffix}}.asc">ASC{{glyphLock}}</a>
    <a {{btnHashStyle}} href="{{downloadsLink}}{{lnkSuffix}}.sha512">SHA{{glyphLock}}</a>
  </div>
</div>
{% endfor %}
<div class="row btn-group-sm" style="margin: 20px">
  <a {{btnDocStyle}} href="{{site.baseurl}}/release/accumulo-{{linkVers}}">Release Notes</a>
  <a {{btnDocStyle}} href="https://github.com/apache/accumulo/blob/rel/{{linkVers}}/README.md">README</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/1.10/accumulo_user_manual">User Manual</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/1.10/examples">Examples</a>
  <a {{btnDocStyle}} href="{{site.baseurl}}/1.10/apidocs">Java API</a>
</div>


## <small><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span></small> Legend
{: #legend }

**LTM**{: .label .label-success} / **non-LTM**{: .label .label-warning} indicates a [Long Term Maintenance][LTM] release or not

**Latest**{: .label .label-primary} / **Legacy**{: .label .label-default} indicates the latest or previous generation


## Older releases

Older releases are listed in the [release archive][ARCHIVE_REL] and can be
downloaded from the [download archive][ARCHIVE_DOWN].


[VERIFY_PROCEDURES]: https://www.apache.org/info/verification "Verify"
[GPG_KEYS]: https://downloads.apache.org/accumulo/KEYS "KEYS"
[ARCHIVE_DOWN]: https://archive.apache.org/dist/accumulo "Download Archive"
[ARCHIVE_REL]: {{site.baseurl}}/release/ "Release Archive"
[LTM]: {{site.baseurl}}/contributor/versioning.html#LTM "LTM Explained"
