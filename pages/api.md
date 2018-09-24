---
title: Public API Definition
permalink: /api/
---

Accumulo's public API is composed of all public types in the following
packages and their sub-packages excluding those named *impl*, *thrift*, or
*crypto*.

 * org.apache.accumulo.core.client
 * org.apache.accumulo.core.data
 * org.apache.accumulo.core.security
 * org.apache.accumulo.minicluster

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

```
import\s+org\.apache\.accumulo\.(.*\.(impl|thrift|crypto)\..*|(?!core|minicluster).*|core\.(?!client|data|security).*)
```

[semver]: http://semver.org/spec/v2.0.0
[RegexpSingleline]: http://checkstyle.sourceforge.net/config_regexp.html
