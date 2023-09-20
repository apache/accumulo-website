---
title: Apache Accumulo 2.1.3
sortableversion: '02.01.03'
draft: true
LTM: true
---
## About

Apache Accumulo 2.1.3 is a patch release of the 2.1 LTM line. It contains bug
fixes and minor enhancements. This version supersedes 2.1.2. Users upgrading to
2.1 should upgrade directly to this version instead of 2.1.2.

Included here are some highlights of the most interesting bugs fixed and
features added in 2.1.3. For the full set of changes, please see the commit
history or issue tracker.

### Notable Improvements

Improvements that affect performance:

* {% ghi 3722 %} Adds parameter {% plink general.filename.base.allocation %}, that allows the batch size
  for unique filename allocation in ZooKeeper to be configurable. In a system that requires large numbers
  of unique names, larger batch sizes can reduce ZooKeeper contention because more file names can be 
  reserved with a single ZooKeeper call.
* {% ghi 3733 %} Avoid creating server side threads when failed writes are cancelled. In versions 2.1.2
  and earlier, the thrift close call creates a new thread to cancel the thrift session. With 2.1.3, an
  new thrift method is available to test if a session is reserved and deletes it if it is not reserved 
  without creating an additional thread.  If the new method is not available it falls back to the previous
  close method to preserve interoperability between 2.x versions.

### Notable Bug Fixes

* {% ghi 3721 %} Fixes issue with writes happening in a retry after batch writer was closed. This
  strengthens metadata consistency.
* {% ghi 3749 %} Fixes issue where deleting a compaction pool with running compactions would
  leave the tserver in a bad state.
* {% ghi 3748 %} Fixes bug where wal could remained locked if an exception occurred.
* {% ghi 3747 %} Adds validation to prevent possible deadlock when acquiring wal locks.
* {% ghi 3737 %} Use custom Transport to set Transport message and frame size. This fixes
  a bug where Accumulo would not change the max message size allowed.
* {% ghi #608 %}, {% ghi 3755 %} Add validation to GC that checks that the scanner used by GC to determine
  candidates for deletion returned a complete row as a mitigation for {% ghi #608 %} where
  garbage collector removes file that are referenced and in-use.

### Improvements that help with administration:

* {% ghi 3697 %} Allow `ACCUMULO_JAVA_PREFIX` option in `accumulo-env.sh` so it can be passed 
  as an array. This simplifies passing user options when starting Accumulo processes, for example
  `numactl` parameters.
* {% ghi 3751 %} Added property {% plink rpc.backlog %} to configure backlog size for
  Thrift server sockets.
* {% ghi 3745 %} Adds prefix to gc deletion log messages. This makes it easier to isolate the deletion
  actions of the garbage collector for analysis.
* {% ghi 3724 %} Adds logging of transactions when metadata and in-memory differences are detected.

## Upgrading

View the [Upgrading Accumulo documentation][upgrade] for guidance.

## 2.1.2 GitHub Project

[All tickets related to 2.1.3.][project]


[upgrade]: /docs/2.x/administration/upgrading
[project]: https://github.com/apache/accumulo/projects/30
