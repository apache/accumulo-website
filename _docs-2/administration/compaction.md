---
title: Compactions
category: administration
order: 6
---

In Accumulo each tablet has a list of files associated with it.  As data is
written to Accumulo it is buffered in memory. The data buffered in memory is
eventually written to files in DFS on a per tablet basis. Files can also be
added to tablets directly by bulk import. In the background tablet servers run
major compactions to merge multiple files into one. The tablet server has to
decide which tablets to compact and which files within a tablet to compact.

Within each tablet server there are one or more user configurable Comapction
Services that compact tablets.  Each Accumulo table has a user configurable
Compaction Dispatcher that decides which compaction services that table will
use.  Accumulo generates metrics for each compaction service which enable users
to adjust compaction service settings based on actual activity.

Each compaction service has a compaction planner that decides which files to
compact.  The default compaction planner uses the table property {% plink
table.compaction.major.ratio %} to decide which files to compact.  The
compaction ratio is real number >= 1.0.  Assume LFS is the size of the largest
file in a set, CR is the compaction ratio,  and FSS is the sum of file sizes in
a set. The default planner looks for file sets where LFS*CR <= FSS.  By only
compacting sets of files that meet this requirement the amount of work done by
compactions is O(N * log<sub>CR</sub>(N)).  Increasing the ratio will
result in less compaction work and more files per tablet.  More files per
tablet means more higher query latency. So adjusting this ratio is a trade off
between ingest and query performance.

When CR=1.0 this will result in a goal of a single per file tablet, but the
amount of work is O(N<sup>2</sup>) so 1.0 should be used with caution.  For
example if a tablet has a 1G file and 1M file is added, then a compaction of
the 1G and 1M file would be queued. 

Compaction services and dispatchers were introduced in Accumulo 2.1, so much
of this documentation only applies to Accumulo 2.1 and later.  

## Configuration

Below are some Accumulo shell commands that do the following :

 * Create a compaction service named `cs1` that has three executors.  The first executor named `small` has 8 threads and runs compactions less than 16M.  The second executor `medium` runs compactions less than 128M with 4 threads.  The last executor `large` runs all other compactions.
 * Create a compaction service named `cs2` that has three executors.  It has similar config to `cs1`, but its executors have less threads. Limits total I/O of all compactions within the service to 40MB/s.
* Configure table `ci` to use compaction service `cs1` for system compactions and service `cs2` for user compactions.

```
config -s tserver.compaction.major.service.cs1.planner=org.apache.accumulo.core.spi.compaction.DefaultCompactionPlanner
config -s 'tserver.compaction.major.service.cs1.planner.opts.executors=[{"name":"small","maxSize":"16M","numThreads":8},{"name":"medium","maxSize":"128M","numThreads":4},{"name":"large","numThreads":2}]'
config -s tserver.compaction.major.service.cs2.planner=org.apache.accumulo.core.spi.compaction.DefaultCompactionPlanner
config -s 'tserver.compaction.major.service.cs2.planner.opts.executors=[{"name":"small","maxSize":"16M","numThreads":4},{"name":"medium","maxSize":"128M","numThreads":2},{"name":"large","numThreads":1}]'
config -s tserver.compaction.major.service.cs2.throughput=40M
config -t ci -s table.compaction.dispatcher=org.apache.accumulo.core.spi.compaction.SimpleCompactionDispatcher
config -t ci -s table.compaction.dispatcher.opts.service=cs1
config -t ci -s table.compaction.dispatcher.opts.service.user=cs2
```

For more information see the javadoc for {% jlink org.apache.accumulo.core.spi.compaction %}, 
{% jlink org.apache.accumulo.core.spi.compaction.DefaultCompactionPlanner %} and 
{% jlink org.apache.accumulo.core.spi.compaction.SimpleCompactionDispatcher %}

The names of the compaction services and executors are used for logging and metrics.

## Logging

The names of compaction services and executors are used in logging.  The log
messages below are from a tserver with the configuration above with data being
written to the ci table.  Also a compaction of the table was forced from the
shell.

```
2020-06-25T16:34:31,669 [tablet.files] DEBUG: Compacting 3;667;6 on cs1.small for SYSTEM from [C00001cm.rf, C00001a7.rf, F00001db.rf] size 15 MB
2020-06-25T16:34:45,165 [tablet.files] DEBUG: Compacted 3;667;6 for SYSTEM created hdfs://localhost:8020/accumulo/tables/3/t-000006f/C00001de.rf from [C00001cm.rf, C00001a7.rf, F00001db.rf]
2020-06-25T16:35:01,965 [tablet.files] DEBUG: Compacting 3;667;6 on cs1.medium for SYSTEM from [C00001de.rf, A000017v.rf, F00001e7.rf] size 33 MB
2020-06-25T16:35:11,686 [tablet.files] DEBUG: Compacted 3;667;6 for SYSTEM created hdfs://localhost:8020/accumulo/tables/3/t-000006f/A00001er.rf from [C00001de.rf, A000017v.rf, F00001e7.rf]
2020-06-25T16:37:12,521 [tablet.files] DEBUG: Compacting 3;667;6 on cs2.medium for USER from [F00001f8.rf, A00001er.rf] size 35 MB config []
2020-06-25T16:37:17,917 [tablet.files] DEBUG: Compacted 3;667;6 for USER created hdfs://localhost:8020/accumulo/tables/3/t-000006f/A00001fr.rf from [F00001f8.rf, A00001er.rf]
```

## Metrics

The numbers of major and minor compactions running and queued is visible on the
Accumulo monitor page. This allows you to see if compactions are backing up
and adjustments to the above settings are needed. When adjusting the number of
threads available for compactions, consider the number of cores and other tasks
running on the nodes.

The numbers displayed on the Accumulo monitor are an aggregate of all
compaction services and executors.  Accumulo emits metrics about the number of
compactions queued and running on each compaction executor.  Accumulo also
emits metrics about the number of files per tablets.  These metrics can be used
to guide adjusting compaction ratios and compaction service configurations to ensure
tablets do not have to many files.

For example if metrics show that some compaction executors within a compaction
service are under utilized while others are over utilized, then the
configuration for compaction service may need to be adjusted.  If the metrics
show that all compaction executors are fully utilized for long periods then
maybe the compaction ratio on a table needs to be increased.

## User compactions

Compactions can be initiated manually for a table. To initiate a minor
compaction, use the `flush` command in the shell. To initiate a major compaction,
use the `compact` command in the shell:

    user@myinstance mytable> compact -t mytable

If needed, the compaction can be canceled using `compact --cancel -t mytable`.

The `compact` command will compact all tablets in a table to one file. Even tablets
with one file are compacted. This is useful for the case where a major compaction
filter is configured for a table. In 1.4, the ability to compact a range of a table
was added. To use this feature specify start and stop rows for the compact command.
This will only compact tablets that overlap the given row range.



