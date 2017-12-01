---
title: Caching
category: administration
order: 11
---

Accumulo tablet servers have a **block cache** that buffers data in memory to limit reads from disk.
This caching has the following benefits:

* reduces latency when reading data
* helps alleviate hotspots in tables

The block cache stores index and data blocks. A typical Accumulo read will perfrom a binary search
over several index blocks followed by a linear scan of one or more data blocks. Each tablet server
has its own block cache that is shared by all hosted tablets. Therefore, block caches are only enabled
for tables where read performance is critical.

## Configuration

While the block cache is enabled by default for the Accumulo metadata tables, it must be enabled
for all other tables by setting the following table properties to `true`:

* [table.cache.block.enable] - enables data block cache on the table
* [table.cache.index.enable] - enables index block cache on the table

These properties can be set in the Accumulo shell using the following command:

    config -t mytable -s table.cache.block.enable=true

Or programatically using [TableOperations.setProperty()][tableops]:

```java
conn.tableOperations().setProperty("mytable", "table.cache.block.enable", "true");
```

The sizes of the index and data block caches can be changed from their defaults by setting
the following properties:

* [tserver.cache.data.size]
* [tserver.cache.index.size]

[table.cache.block.enable]: {{ page.docs_baseurl }}/administration/configuration-properties#table_cache_block_enable
[table.cache.index.enable]: {{ page.docs_baseurl }}/administration/configuration-properties#table_cache_index_enable
[tserver.cache.data.size]: {{ page.docs_baseurl }}/administration/configuration-properties#tserver_cache_data_size
[tserver.cache.index.size]: {{ page.docs_baseurl }}/administration/configuration-properties#tserver_cache_data_size
[tableops]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/admin/TableOperations.html#setProperty(java.lang.String, java.lang.String, java.lang.String)
