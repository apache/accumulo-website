---
title: Compactions
category: administration
order: 6
---

In Accumulo each tablet has a list of files associated with it.  As data is
written to Accumulo it is buffered in memory. The data buffered in memory is
eventually written to files, called a minor compaction, in DFS on a per-tablet
basis. Files can also be added to tablets directly by bulk import. Compactors
run major compactions to merge multiple files into one. The Manager decides
which tablets to compact and which files within a tablet to compact.

Within the instance configuration one or more Compaction Services can be
configured. These services may use one or more Compactor resource groups
in which to compact files.

Each Accumulo table has a user configurable Compaction Dispatcher that decides
which compaction services that table will use.  Accumulo generates metrics for
each compaction service which enable users to adjust compaction service settings
based on actual activity.

Each compaction service has a compaction planner that decides which files to
compact.  The default compaction planner uses the table property {% plink
table.compaction.major.ratio %} to decide which files to compact.  The
compaction ratio is real number >= 1.0.  Assume LFS is the size of the largest
file in a set, CR is the compaction ratio,  and FSS is the sum of file sizes in
a set. The default planner looks for file sets where LFS*CR <= FSS.  By only
compacting sets of files that meet this requirement the amount of work done by
compactions is O(N * log<sub>CR</sub>(N)).  Increasing the ratio will
result in less compaction work and more files per tablet.  More files per
tablet means higher query latency. So adjusting this ratio is a trade-off
between ingest and query performance.

When CR=1.0 this will result in a goal of a single per file tablet, but the
amount of work is O(N<sup>2</sup>) so 1.0 should be used with caution.  For
example if a tablet has a 1G file and 1M file is added, then a compaction of
the 1G and 1M file would be queued.

## Configuration

Below are some Accumulo shell commands that do the following :

 * Create a compaction service named `cs1` that uses Compactors from three Resource Groups.  The first group named `small` will run compactions less than 16M.  The second group `medium` runs compactions less than 128M.  The last group `large` runs all other compactions.
 * Create a compaction service named `cs2` that uses three different Resource Groups. It has similar config to `cs1`, but the Compactors in the Resource Groups can be configured differently. The configuration also limits total I/O of all compactions within the service to 40MB/s.
* Configure table `ci` to use compaction service `cs1` for system compactions and service `cs2` for user compactions.

```
config -s compaction.service.cs1.planner=org.apache.accumulo.core.spi.compaction.RatioBasedCompactionPlanner
config -s 'compaction.service.cs1.planner.opts.groups=[{"name":"small","maxSize":"16M"},{"name":"medium","maxSize":"128M"},{"name":"large"}]'
config -s compaction.service.cs2.planner=org.apache.accumulo.core.spi.compaction.RatioBasedCompactionPlanner
config -s 'compaction.service.cs2.planner.opts.groups=[{"name":"small_user","maxSize":"16M"},{"name":"medium_user","maxSize":"128M"},{"name":"large_user"}]'
config -s compaction.service.cs2.rate.limit=40M
config -t ci -s table.compaction.dispatcher=org.apache.accumulo.core.spi.compaction.SimpleCompactionDispatcher
config -t ci -s table.compaction.dispatcher.opts.service=cs1
config -t ci -s table.compaction.dispatcher.opts.service.user=cs2
```

For more information see the javadoc for {% jlink org.apache.accumulo.core.spi.compaction %},
{% jlink org.apache.accumulo.core.spi.compaction.RatioBasedCompactionPlanner %} and
{% jlink org.apache.accumulo.core.spi.compaction.SimpleCompactionDispatcher %}

The names of the compaction services and executors are used for logging and metrics.

## Compaction Coordinator

The CompactionCoordinator is a function that runs inside the Manager. It is responsible for managing the global major compaction work queue. For each Compactor Resource Group, the CompactionCoordinator will maintain an in memory priority queue of the tablets that require major compactions. As the Manager processes metadata for each Tablet it determines if a major compaction is required and adds the information to the Coordinator's work queue. 

When a Compactor is free to perform work, it asks the CompactionCoordinator for the next compaction job. The CompactionCoordinator returns job information for the Tablet that has the highest priority for the Compactor's Resource Group. The Compaction Coordinator maintains the state of running compactions and also inserts an entry into the metadata table for the tablet to denote that an external compaction is running. When the Compactor has finished the compaction, it notifies the CompactionCoordinator which inserts an entry into the metadata table to denote that the external compaction completed and, if successful, commits the major compaction.

Compactors handle faults and major system events in Accumulo. When a Compactor process dies this will be detected and any files it had reserved in a tablet will be unreserved. Tablets being deleted (by split, merge, or table deletion) will cause any associated running compactions to be canceled.  When a user initiated compaction is canceled, any compactions running as part of that will be canceled.

## Metrics

The numbers of major and minor compactions running and queued is visible on the
Accumulo monitor page. This allows you to see if compactions are backing up
and adjustments to the above settings are needed. When adjusting the number of
Compactors available for compactions, consider the number of cores and other tasks
running on the nodes.

The numbers displayed on the Accumulo monitor are an aggregate. If metrics show
that some Compactors within a Resource Group are under utilized while others are
over utilized, then the configuration for the number of Compactors may need to be
adjusted.  If the metrics show that all Compactors are fully utilized for long
periods then maybe the compaction ratio on a table needs to be increased.

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

