---
title: "Why Upgrade to Accumulo 2.0"
author: Mike Miller
---

Accumulo 2.0 has been in development for quite some time now and is packed with new features, bug
fixes, performance improvements and redesigned components.  All of these changes bring challenges
when upgrading your production cluster so you may be wondering... why should I upgrade?

My top 10 reasons to upgrade. For all changes see the [release notes][rel]

* [Summaries](#summaries)
* [New Bulk Import](#new-bulk-import)
* [Simplified Scripts and Config](#simplified-scripts-and-config)
* [New Monitor](#new-monitor)
* [New Accumulo Client](#new-accumulo-client)
* [Hadoop 3](#hadoop-3-support)
* [Offline creation](#offline-creation)
* [Search Documentation](#search-documentation)
* [Java 11 Support](#java-8-11-support)
* [On disk encryption](#new-crypto)

### Summaries

This feature allows detailed stats about Tables to be written directly into Accumulo files (R-Files). 
Summaries can be used to make precise decisions about your data. Once configured, summaries become a 
part of your Tables, so they won't impact ingest or query performance of your cluster.

Here are some example use cases:

* A compaction could automatically run if deletes compose more than 25% of the data
* An admin could optimize compactions by configuring specific age off of data
* An admin could analyze R-File summaries for better performance tuning of a cluster

For more info check out the [summary docs for 2.0][summary]

### New Bulk Import

Bulk Ingest was completely redone for 2.0.  Previously, Bulk Ingest relied on expensive inspections of 
R-Files across multiple Tablet Servers. With enough data, an old Bulk Ingest operation could easily 
hold up simpler Table operations and critical compactions of files.

The new Bulk Ingest gives the user control over the R-File inspection, allows for offline bulk
ingesting and provides performance [improvements][new-bulk].

## Simplified Scripts and Config

Many improvements were done to the scripts and configuration. See Mike's description of the [improvements.][scripts]

## New Monitor

The Monitor has been re-written using REST, Javascript and more modern Web Tech.  It is faster, 
cleaner and more maintainable than the previous version. Here is a screen shot:

<img src="{{ site.baseurl }}/images/accumulo-monitor-1.png" width="50%"/>

## New Accumulo Client

Connecting to Accumulo is now easier with a single point of entry for clients. It can now be done with 
a fluent API, 2 imports (AccumuloClient & Accumulo) and using minimal code:

```java
try (AccumuloClient client = Accumulo.newClient()
          .to("instance", "zk")
          .as("user", "pass").build()) {
      // use the client
      client.tableOperations().create("newTable");
    }
```

As you can see the client is also closable, which gives developers more control over resources.
See the [Accumulo entry point javadoc][client] for more info. 

## Hadoop 3 Support

Upgrading to Hadoop 3 brings all the fixes and improvements that have been made to Hadoop over the
years to your cluster.  [Checkout all the new features of Hadoop 3][hadoop3]. 

## Offline creation

Tables can now be created with splits offline.  This frees up online resources to perform other critical operations.
See the [GitHub issue][offline].

## Search Documentation

New ability to quickly search documentation on the website. The user manual was completely redone 
for 2.0. Check it out [here][manual]. Users can now quickly [search] the website across all 2.0 documentation.

## Java 8-11 Support

Accumulo 2.0 will work with versions of Java up to 11.  It is not required, but will build and run with Java 11.

## New Crypto

On disk encryption was redone to be more secure and flexible. For an in depth description of how Accumulo 
does on disk encryption, see the [user manual][crypto].

[FATE]: {% dlink /administration/fate %}
[new-bulk]: https://accumulo.apache.org/release/accumulo-2.0.0/#new-bulk-import-api
[scripts]: https://accumulo.apache.org/blog/2016/11/16/simpler-scripts-and-config.html
[summary]: {% dlink /development/summaries %}
[client]: {% jurl org.apache.accumulo.core.client.Accumulo %}
[hadoop3]: https://hadoop.apache.org/docs/r3.0.0/
[offline]: {% ghi 573 %}
[manual]: {% dlink /getting-started/quickstart %}
[search]: https://accumulo.apache.org/search/
[crypto]: https://accumulo.apache.org/docs/2.x/security/on-disk-encryption
[rel]: https://accumulo.apache.org/release/accumulo-2.0.0/