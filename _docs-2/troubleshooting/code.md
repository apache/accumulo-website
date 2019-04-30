---
title: Codebase Overview
category: troubleshooting
order: 7
---

If you are trying to troubleshoot an Accumulo problem, you should first try and find help within Accumulo's documentation. The Accumulo
website's [search tool](https://accumulo.apache.org/search/) can help in finding relevant documentation.

If you cannot find relevant documentation for your problem, you might want to review Accumulo's code to learn more about the code that
is causing the problem and find a potential solution for it. This documentation provides an overview of Accumulo's codebase to get you
started.

## Master

The [Master] has the following responsibilities:

  * [detect and respond][update] to [TabletServer] failures
  * assign and balance tablets to Tablet Servers using a [TabletBalancer]
  * handle table creation, alteration and deletion requests from clients using the [TableManager]
  * coordinate changes to write-ahead logs using the [WalStateManager].
  * report general status

## Metadata Tables

  * Accumulo has two metadata tables
     * accumulo.metadata table (id: !0) contains metadata for user tables
     * accumulo.root table (id: +r) contains metadata for accumulo.metadata
  * metadata for the accumulo.root table is stored in ZooKeeper
  * tables are read using [MetaDataTableScanner]
  * tables are modified using [MetadataTableUtil]

## Tablet Server

The [TabletServer] has the following responsiblities:

  * [receives writes] from clients
  * [retrieves] the [Tablet] that should be written to
  * [persists writes] to a write-ahead log using [TabletServerLogger]
  * sorts new key/value pairs in memory
  * periodically [flush] sorted key/value pairs to new RFiles in HDFS
  * responds to reads from clients and form a sorted merge view of all
    key/value pairs from all files & memory
  * perform recovery of a [Tablet] that was previously on a server that failed
    and reapply any writes found in the write-ahead log to the tablet

## Garbage Collector

The [GarbageCollector] has the following repsonsibilities:

  * [identify RFiles] in HDFS that are no longer needed and delete them
  * multiple garbage collectors can be run to provide hot-standby support

[Master]: {% ghcu server/master/src/main/java/org/apache/accumulo/master/Master.java %}
[update]: {% ghcu server/master/src/main/java/org/apache/accumulo/master/Master.java#L1332 %}
[retrieves]: {% ghcu server/tserver/src/main/java/org/apache/accumulo/tserver/TabletServer.java#L1251 %}
[Tablet]: {% ghcu server/tserver/src/main/java/org/apache/accumulo/tserver/tablet/Tablet.java %}
[TabletServer]: {% ghcu server/tserver/src/main/java/org/apache/accumulo/tserver/TabletServer.java %}
[TabletBalancer]: {% ghcu server/base/src/main/java/org/apache/accumulo/server/master/balancer/TabletBalancer.java %}
[TableManager]: {% ghcu server/base/src/main/java/org/apache/accumulo/server/tables/TableManager.java %}
[WalStateManager]: {% ghcu server/base/src/main/java/org/apache/accumulo/server/log/WalStateManager.java %}
[MetadataTableScanner]: {% ghcu server/base/src/main/java/org/apache/accumulo/server/master/state/MetaDataTableScanner.java %}
[MetadataTableUtil]: {% ghcu server/base/src/main/java/org/apache/accumulo/server/util/MetadataTableUtil.java %}
[receives writes]: {% ghcu server/tserver/src/main/java/org/apache/accumulo/tserver/TabletServer.java#L1240 %}
[persists writes]: {% ghcu server/tserver/src/main/java/org/apache/accumulo/tserver/TabletServer.java#L1289 %}
[TabletServerLogger]: {% ghcu server/tserver/src/main/java/org/apache/accumulo/tserver/log/TabletServerLogger.java %}
[flush]: {% ghcu server/tserver/src/main/java/org/apache/accumulo/tserver/TabletServer.java#L1809 %}
[GarbageCollector]: {% ghcu server/gc/src/main/java/org/apache/accumulo/gc/SimpleGarbageCollector.java %}
[identify RFiles]: {% ghcu server/gc/src/main/java/org/apache/accumulo/gc/GarbageCollectionAlgorithm.java#L290 %}
