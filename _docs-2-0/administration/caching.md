---
title: Caching
category: administration
order: 11
---

Accumulo [tablet servers][tserver] have **block caches** that buffer data in memory to limit reads from disk.
This caching has the following benefits:

* reduces latency when reading data
* helps alleviate hotspots in tables

Each tablet server has an index and data block cache that is shared by all hosted tablets (see the [tablet server diagram][tserver]
to learn more). A typical Accumulo read operation will perform a binary search over several index blocks followed by a linear scan
of one or more data blocks. If these blocks are not in a cache, they will need to be retrieved from [RFiles] in HDFS. While the index
block cache is enabled for all tables, the data block cache has to be enabled for a table by the user. It is typically only enabled
for tables where read performance is critical.

## Configuration

The index and data block caches are configured for tables by the following properties:

* [table.cache.block.enable] - enables data block cache on the table (default is `false`)
* [table.cache.index.enable] - enables index block cache on the table (default is `true`)

While the index block cache is enabled by default for all Accumulo tables, users must enable the data block cache by
settting [table.cache.block.enable] to `true` in the shell:

    config -t mytable -s table.cache.block.enable=true

Or programatically using [TableOperations.setProperty()][tableops]:

```java
conn.tableOperations().setProperty("mytable", "table.cache.block.enable", "true");
```

The size of the index and data block caches (which are shared by all tablets of tablet server) can be changed from
their defaults by setting the following properties:

* [tserver.cache.data.size]
* [tserver.cache.index.size]

[tserver]: {{ page.docs_baseurl }}/getting-started/design#tablet-server-1
[RFiles]: {{ page.docs_baseurl}}/getting-started/design#rfile
[table.cache.block.enable]: {{ page.docs_baseurl }}/administration/properties#table_cache_block_enable
[table.cache.index.enable]: {{ page.docs_baseurl }}/administration/properties#table_cache_index_enable
[tserver.cache.data.size]: {{ page.docs_baseurl }}/administration/properties#tserver_cache_data_size
[tserver.cache.index.size]: {{ page.docs_baseurl }}/administration/properties#tserver_cache_data_size
[tableops]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/admin/TableOperations.html#setProperty(java.lang.String, java.lang.String, java.lang.String)
