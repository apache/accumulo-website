---
title: Performance
category: troubleshooting
order: 5
---

Accumulo can be tuned to improve read and write performance.

## Read performance

1. Enable [caching] on tables to reduce reads to disk.

1. Enable [bloom filters][bloom-filters] on tables to limit the number of disk lookups.

1. Decrease the [major compaction ratio][compaction] of a table to decrease the number of
   files per tablet. Less files reduces the latency of reads.

1. Decrease the size of [data blocks in RFiles][rfile] by lowering {% plink table.file.compress.blocksize %} which can result
   in better random seek performance. However, this can increase the size of indexes in the RFile. If the indexes
   are too large to fit in cache, this can hinder performance. Also, as the index size increases the depth of the
   index tree in each file may increase. Increasing {% plink table.file.compress.blocksize.index %} can reduce the depth of
   the tree.

## Write performance

1. Enable [native maps][native-maps] on tablet servers to prevent Java garbage collection pauses
   which can slow ingest.

1. [Pre-split new tables][split] to distribute writes across multiple tablet servers.

1. Ingest data using [multiple clients][multi-client] or [bulk ingest][bulk] to increase ingest throughput.

1. Increase the [major compaction ratio][compaction] of a table to limit the number of major compactions
   which improves ingest performance.

1. On large Accumulo clusters, use [multiple HDFS volumes][multivolume] to increase write performance.

1. Change the compression format used by [blocks in RFiles][rfile] by setting {% plink table.file.compress.type %} to
   `snappy`. This increases write speed at the expense of using more disk space.

[caching]: {% durl administration/caching %}
[bloom-filters]: {% durl getting-started/table_configuration#bloom-filters %}
[compaction]: {% durl getting-started/table_configuration#compaction %}
[rfile]: {% durl getting-started/design#rfile %}
[native-maps]: {% durl administration/in-depth-install#native-map %}
[split]: {% durl getting-started/table_configuration#pre-splitting-tables %}
[multi-client]: {% durl development/high_speed_ingest#multiple-ingest-clients %}
[bulk]: {% durl development/high_speed_ingest#bulk-ingest %}
[multivolume]: {% durl administration/multivolume %}
