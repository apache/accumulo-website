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

## Write performance

1. Enable [native maps][native-maps] on tablet servers to prevent Java garbage collection pauses
   which can slow ingest.

1. [Pre-split new tables][split] to distribute writes across multiple tablet servers.

1. Ingest data using [multiple clients][multi-client] or [bulk ingest][bulk] to increase ingest throughput.

1. Increase the [major compaction ratio][compaction] of a table to limit the number of major compactions
   which improves ingest peformance.

1. On large Accumulo clusters, use [multiple HDFS volumes][multivolume] to increase write peformance.

[caching]: {{ page.docs_baseurl }}/administration/caching
[bloom-filters]: {{ page.docs_baseurl }}/getting-started/table_configuration#bloom-filters
[compaction]: {{ page.docs_baseurl }}/getting-started/table_configuration#compaction
[native-maps]: {{ page.docs_baseurl }}/administration/in-depth-install#native-map
[split]: {{ page.docs_baseurl }}//getting-started/table_configuration#pre-splitting-tables
[multi-client]: {{ page.docs_baseurl }}/development/high_speed_ingest#multiple-ingest-clients
[bulk]: {{ page.docs_baseurl }}/development/high_speed_ingest#bulk-ingest
[multivolume]: {{ page.docs_baseurl }}/administration/multivolume
