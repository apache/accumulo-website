---
title: Caching
category: administration
order: 6
---

Accumulo Scan Servers and [Tablet Servers][tserver] have **block caches** that buffer data in memory to limit reads from disk.
This caching has the following benefits:

* reduces latency when reading data
* helps alleviate hotspots in tables

Each Scan / Tablet Server has an index and data block cache that is shared by all hosted tablets (see the [tablet server diagram][tserver]
to learn more). A typical Accumulo read operation will perform a binary search over several index blocks followed by a linear scan
of one or more data blocks. If these blocks are not in a cache, they will need to be retrieved from [RFiles] in HDFS. While the index
block cache is enabled for all tables, the data block cache has to be enabled for a table by the user. It is typically only enabled
for tables where read performance is critical.

## Configuration

The {% plink general.block.cache.manager.class %} property controls which block cache implementation is used within the server. Users
can supply their own implementation and set custom configuration properties to control its behavior (see org.apache.accumulo.core.spi.cache.BlockCacheManager$Configuration.java).

The index and data block caches are configured for tables by the following properties:

* {% plink table.cache.block.enable %} - enables data block cache on the table (default is `false`)
* {% plink table.cache.index.enable %} - enables index block cache on the table (default is `true`)

While the index block cache is enabled by default for all Accumulo tables, users must enable the data block cache by
setting {% plink table.cache.block.enable %} to `true` in the shell at the namespace or table level:

    config -ns mynamespace -s table.cache.block.enable=true
    config -t mytable -s table.cache.block.enable=true

Or programmatically using [NamespaceOperations.setProperty()][namespaceops] or [TableOperations.setProperty()][tableops]:

```java
client.namespaceOperations().setProperty("mynamespace", "table.cache.block.enable", "true");
client.tableOperations().setProperty("mytable", "table.cache.block.enable", "true");
```

The size of the index and data block caches (which are shared by all tablets of the server) can be changed from
their defaults by setting the following properties:

* {% plink sserver.cache.data.size %}
* {% plink sserver.cache.index.size %}
* {% plink tserver.cache.data.size %}
* {% plink tserver.cache.index.size %}

[tserver]: {% durl getting-started/design#tablet-server-1 %}
[RFiles]: {% durl getting-started/design#rfile %}
[namespaceops]: {% jurl org.apache.accumulo.core.client.admin.NamespaceOperations#setProperty-java.lang.String-java.lang.String-java.lang.String- %}
[tableops]: {% jurl org.apache.accumulo.core.client.admin.TableOperations#setProperty-java.lang.String-java.lang.String-java.lang.String- %}
