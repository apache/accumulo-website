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
$(function() { $.getJSON("https://accumulo.apache.org/mirrors.cgi?as_json", mirrorsCallback); });

</script>

<div id="mirror_selection"></div>

**LTM**{: .label .label-success} / **non-LTM**{: .label .label-warning} indicates a [Long Term Maintenance][LTM] release or not  
**Latest**{: .label .label-primary} / **Legacy**{: .label .label-default} indicates the latest or previous generation

Be sure to verify your downloads by these [procedures][VERIFY_PROCEDURES] using these [KEYS][GPG_KEYS].

## Current Releases

---

### 2.0.0 **Latest**{: .label .label-primary} **non-LTM**{: .label .label-warning}
{: #latest }

The 2.0.0 release of Apache Accumulo&reg; is the latest release, containing
the newest features, bug fixes, performance enhancements, and more.
See the [release notes][REL_NOTES_20] for more details about this release.

{: .table }
| **Binary** | [accumulo-2.0.0-bin.tar.gz][BIN_20] | [ASC][ASC_BIN_20] | [SHA][SHA_BIN_20] |
| **Source** | [accumulo-2.0.0-src.tar.gz][SRC_20] | [ASC][ASC_SRC_20] | [SHA][SHA_SRC_20] |

#### 2.0 Documentation
* [README][README_20]
* [Online Documentation][MANUAL_20]
* [Java API][JAVADOC_20]

### 1.10.0 **Legacy**{: .label .label-default} **LTM**{: .label .label-success}
{: #legacy }

The most recent legacy (1.x) release of Apache Accumulo&reg; is version 1.10.0.
See the [release notes][REL_NOTES_1x] for more details about this release.

{: .table }
| **Binary** | [accumulo-1.10.0-bin.tar.gz][BIN_1x] | [ASC][ASC_BIN_1x] | [SHA][SHA_BIN_1x] |
| **Source** | [accumulo-1.10.0-src.tar.gz][SRC_1x] | [ASC][ASC_SRC_1x] | [SHA][SHA_SRC_1x] |

#### 1.10 Documentation
* [README][README_1x]
* [User Manual][MANUAL_1x]
* [Examples][EXAMPLES_1x]
* [Java API][JAVADOC_1x]

## Older releases

Older releases are listed in the [release archive][ARCHIVE_REL] and can be
downloaded from the [download archive][ARCHIVE_DOWN].

[VERIFY_PROCEDURES]: https://www.apache.org/info/verification "Verify"
[GPG_KEYS]: https://downloads.apache.org/accumulo/KEYS "KEYS"
[ARCHIVE_DOWN]: https://archive.apache.org/dist/accumulo "Download Archive"
[ARCHIVE_REL]: {{ site.baseurl }}/release/ "Release Archive"

[ASC_BIN_20]: https://downloads.apache.org/accumulo/2.0.0/accumulo-2.0.0-bin.tar.gz.asc
[ASC_SRC_20]: https://downloads.apache.org/accumulo/2.0.0/accumulo-2.0.0-src.tar.gz.asc
[SHA_BIN_20]: https://downloads.apache.org/accumulo/2.0.0/accumulo-2.0.0-bin.tar.gz.sha512
[SHA_SRC_20]: https://downloads.apache.org/accumulo/2.0.0/accumulo-2.0.0-src.tar.gz.sha512
[ASC_BIN_1x]: https://downloads.apache.org/accumulo/1.10.0/accumulo-1.10.0-bin.tar.gz.asc
[ASC_SRC_1x]: https://downloads.apache.org/accumulo/1.10.0/accumulo-1.10.0-src.tar.gz.asc
[SHA_BIN_1x]: https://downloads.apache.org/accumulo/1.10.0/accumulo-1.10.0-bin.tar.gz.sha512
[SHA_SRC_1x]: https://downloads.apache.org/accumulo/1.10.0/accumulo-1.10.0-src.tar.gz.sha512

[BIN_20]: https://www.apache.org/dyn/closer.lua/accumulo/2.0.0/accumulo-2.0.0-bin.tar.gz
{: link-suffix="/accumulo/2.0.0/accumulo-2.0.0-bin.tar.gz" }
[SRC_20]: https://www.apache.org/dyn/closer.lua/accumulo/2.0.0/accumulo-2.0.0-src.tar.gz
{: link-suffix="/accumulo/2.0.0/accumulo-2.0.0-src.tar.gz" }
[BIN_1x]: https://www.apache.org/dyn/closer.lua/accumulo/1.10.0/accumulo-1.10.0-bin.tar.gz
{: link-suffix="/accumulo/1.10.0/accumulo-1.10.0-bin.tar.gz" }
[SRC_1x]: https://www.apache.org/dyn/closer.lua/accumulo/1.10.0/accumulo-1.10.0-src.tar.gz
{: link-suffix="/accumulo/1.10.0/accumulo-1.10.0-src.tar.gz" }

[README_20]: https://github.com/apache/accumulo/blob/rel/2.0.0/README.md
[README_1x]: https://github.com/apache/accumulo/blob/rel/1.10.0/README.md

[JAVADOC_20]: {{ site.baseurl }}/docs/2.x/apidocs/
[JAVADOC_1x]: {{ site.baseurl }}/1.10/apidocs/

[MANUAL_20]: {{ site.baseurl }}/docs/2.x "2.x online manual"
[MANUAL_1x]: {{ site.baseurl }}/1.10/accumulo_user_manual "1.10 user manual"

[EXAMPLES_1x]: {{ site.baseurl }}/1.10/examples "1.10 examples"

[REL_NOTES_20]: {{ site.baseurl }}/release/accumulo-2.0.0/ "2.0.0 Release Notes"
[REL_NOTES_1x]: {{ site.baseurl }}/release/accumulo-1.10.0/ "1.10.0 Release Notes"

[LTM]: {{ site.baseurl }}/contributor/versioning.html#LTM "LTM Explained"
