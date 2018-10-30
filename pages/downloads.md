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
  htmlContent += '<optgroup label="HTTP Mirrors">';
  for (var i = 0; i < json.http.length; i++) {
    htmlContent += '<option>' + json.http[i] + '</option>';
  }
  htmlContent += '</optgroup>';
  htmlContent += '<optgroup label="FTP Mirrors">';
  for (var i = 0; i < json.ftp.length; i++) {
    htmlContent += '<option>' + json.ftp[i] + '</option>';
  }
  htmlContent += '</optgroup>';
  htmlContent += '<optgroup label="Backup Mirrors">';
  for (var i = 0; i < json.backup.length; i++) {
    htmlContent += '<option>' + json.backup[i] + '</option>';
  }
  htmlContent += '</optgroup>';
  htmlContent += '</select></div></div>';

  $("#mirror_selection").html(htmlContent);

  $( "#apache-mirror-select" ).change(function() {
    var mirror = $("#apache-mirror-select option:selected").text();
    updateLinks(mirror);
  });

  updateLinks(json.preferred);
};

// get mirrors when page is ready
var mirrorURL = window.location.protocol + "//accumulo.apache.org/mirrors.cgi"; // http[s]://accumulo.apache.org/mirrors.cgi
$(function() { $.getJSON(mirrorURL + "?as_json", mirrorsCallback); });

</script>

<div id="mirror_selection"></div>

Be sure to verify your downloads by these [procedures][VERIFY_PROCEDURES] using these [KEYS][GPG_KEYS].

## Current Releases

### 2.0.0-alpha-1 **preview**{: .label .label-primary}

The 2.0.0-alpha-1 release of Apache Accumulo&reg; has been made available as a
preview release for 2.0.0. This version is *not* suitable for production use,
and should be used for feedback and testing purposes only. See the
[release notes][REL_NOTES_20] for more details.

{: .table }
| **Binary** | [accumulo-2.0.0-alpha-1-bin.tar.gz][BIN_20] | [ASC][ASC_BIN_20] | [SHA][SHA_BIN_20] |
| **Source** | [accumulo-2.0.0-alpha-1-src.tar.gz][SRC_20] | [ASC][ASC_SRC_20] | [SHA][SHA_SRC_20] |

#### 2.0 Documentation
* [README][README_20]
* [Online Documentation][MANUAL_20]
* [Java API][JAVADOC_20]

### 1.9.2 **latest**{: .label .label-primary }

The most recent stable Apache Accumulo&reg; release is version 1.9.2. See the [release notes][REL_NOTES_19].

{: .table }
| **Binary** | [accumulo-1.9.2-bin.tar.gz][BIN_19] | [ASC][ASC_BIN_19] | [SHA][SHA_BIN_19] |
| **Source** | [accumulo-1.9.2-src.tar.gz][SRC_19] | [ASC][ASC_SRC_19] | [SHA][SHA_SRC_19] |

#### 1.9 Documentation
* [README][README_19]
* [User Manual][MANUAL_19]
* [Examples][EXAMPLES_19]
* [Java API][JAVADOC_19]

## Older releases

Older releases are listed in the [release archive][ARCHIVE_REL] and can be
downloaded from the [download archive][ARCHIVE_DOWN].

[VERIFY_PROCEDURES]: https://www.apache.org/info/verification "Verify"
[GPG_KEYS]: https://www.apache.org/dist/accumulo/KEYS "KEYS"
[ARCHIVE_DOWN]: https://archive.apache.org/dist/accumulo "Download Archive"
[ARCHIVE_REL]: {{ site.baseurl }}/release/ "Release Archive"

[ASC_BIN_20]: https://www.apache.org/dist/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-bin.tar.gz.asc
[ASC_SRC_20]: https://www.apache.org/dist/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-src.tar.gz.asc
[SHA_BIN_20]: https://www.apache.org/dist/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-bin.tar.gz.sha512
[SHA_SRC_20]: https://www.apache.org/dist/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-src.tar.gz.sha512
[ASC_BIN_19]: https://www.apache.org/dist/accumulo/1.9.2/accumulo-1.9.2-bin.tar.gz.asc
[ASC_SRC_19]: https://www.apache.org/dist/accumulo/1.9.2/accumulo-1.9.2-src.tar.gz.asc
[SHA_BIN_19]: https://www.apache.org/dist/accumulo/1.9.2/accumulo-1.9.2-bin.tar.gz.sha512
[SHA_SRC_19]: https://www.apache.org/dist/accumulo/1.9.2/accumulo-1.9.2-src.tar.gz.sha512

[BIN_20]: https://www.apache.org/dyn/closer.lua/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-bin.tar.gz
{: .download_external link-suffix="/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-bin.tar.gz" id="/downloads/accumulo-2.0.0-alpha-1-bin.tar.gz" }
[SRC_20]: https://www.apache.org/dyn/closer.lua/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-src.tar.gz
{: .download_external link-suffix="/accumulo/2.0.0-alpha-1/accumulo-2.0.0-alpha-1-src.tar.gz" id="/downloads/accumulo-2.0.0-alpha-1-src.tar.gz" }
[BIN_19]: https://www.apache.org/dyn/closer.lua/accumulo/1.9.2/accumulo-1.9.2-bin.tar.gz
{: .download_external link-suffix="/accumulo/1.9.2/accumulo-1.9.2-bin.tar.gz" id="/downloads/accumulo-1.9.2-bin.tar.gz" }
[SRC_19]: https://www.apache.org/dyn/closer.lua/accumulo/1.9.2/accumulo-1.9.2-src.tar.gz
{: .download_external link-suffix="/accumulo/1.9.2/accumulo-1.9.2-src.tar.gz" id="/downloads/accumulo-1.9.2-src.tar.gz" }

[README_20]: https://github.com/apache/accumulo/blob/rel/2.0.0-alpha-1/README.md
{: .download_external id="/2.0-alpha-1/README" }
[README_19]: https://github.com/apache/accumulo/blob/rel/1.9.2/README.md
{: .download_external id="/1.9/README" }

[JAVADOC_20]: {{ site.baseurl }}/docs/2.x/apidocs/
{: .download_external id="/docs/2.x/apidocs/" }
[JAVADOC_19]: {{ site.baseurl }}/1.9/apidocs/
{: .download_external id="/1.9/apidocs/" }

[MANUAL_20]: {{ site.baseurl }}/docs/2.x "2.x online manual"
[MANUAL_19]: {{ site.baseurl }}/1.9/accumulo_user_manual "1.9 user manual"

[EXAMPLES_19]: {{ site.baseurl }}/1.9/examples "1.9 examples"

[REL_NOTES_20]: {{ site.baseurl }}/release/accumulo-2.0.0-alpha-1/ "2.0.0-alpha-1 Release Notes"
[REL_NOTES_19]: {{ site.baseurl }}/release/accumulo-1.9.2/ "1.9.2 Release Notes"

