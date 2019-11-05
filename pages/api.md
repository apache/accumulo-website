---
title: Public API Definition
permalink: /api/
---

Accumulo's public API is composed of all public types in the following
packages and their sub-packages excluding those named *impl*, *thrift*, or
*crypto*.

 * {% jlink -f org.apache.accumulo.core.client %}
 * {% jlink -f org.apache.accumulo.core.data %}
 * {% jlink -f org.apache.accumulo.core.security %}
 * {% jlink -f org.apache.accumulo.minicluster %}
 * {% jlink -f org.apache.accumulo.hadoop %} (since 2.0.0)

A type is a class, interface, or enum. Anything with public or protected
access in an API type is in the API. This includes, but is not limited to:
methods, members classes, interfaces, and enums. Package-private types in the
above packages are *not* considered public API.

The Accumulo project maintains binary compatibility across this API within a
major release, as defined in the Java Language Specification 3rd ed. Starting
with Accumulo 1.6.2 and 1.7.0 all API changes follow [semver 2.0][semver].
Accumulo code outside of the defined API does not follow semver and may change
in incompatible ways at any release.

The following regex matches imports that are *not* Accumulo public API. This
regex can be used with [RegexpSingleline] to automatically find suspicious
imports in a project using Accumulo.

For 1.9 and earlier:

```regex
import\s+org\.apache\.accumulo\.(.*\.(impl|thrift|crypto)\..*|(?!(core\.(client|data|security)|minicluster)\.).*)
```

For 2.0 and later, this can be simplified, because sub-packages not intended
for public API were relocated, and also altered to include the new MapReduce module:

```regex
import\s+org\.apache\.accumulo\.(?!(core\.(client|data|security)|minicluster|hadoop)\.).*
```

See the [blog post][post] about using the checkstyle plugin for more explicit non-API detection.

[semver]: http://semver.org/spec/v2.0.0
[RegexpSingleline]: http://checkstyle.sourceforge.net/config_regexp.html
[post]: {{ site.baseurl }}/blog/2019/11/04/checkstyle-import-control.html
