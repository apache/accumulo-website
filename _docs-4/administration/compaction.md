---
title: Compactions
category: administration
order: 6
---

In Accumulo each tablet has a list of files associated with it.  As data is
written to Accumulo it is buffered in memory. The data buffered in memory is
eventually written to files in DFS on a per-tablet basis. Files can also be
added to tablets directly by bulk import. In the background tablet servers run
major compactions to merge multiple files into one. The tablet server has to
decide which tablets to compact and which files within a tablet to compact.

Within each tablet server there are one or more user configurable Compaction
Services that compact tablets.  Compaction Services can be configured with
one or more named queues, which may use internal executors or external executors.
An internal executor will be configured with some sized threshold and number of
threads in which to compact files. An external executor is configured only with
the name of an external queue.

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

Compaction services and dispatchers were introduced in Accumulo 2.1, so much
of this documentation only applies to Accumulo 2.1 and later.

## Configuration

Below are some Accumulo shell commands that do the following :

 * Create a compaction service named `cs1` that has three executors.  The first executor named `small` has 8 threads and runs compactions less than 16M.  The second executor `medium` runs compactions less than 128M with 4 threads.  The last executor `large` runs all other compactions.
 * Create a compaction service named `cs2` that has three executors.  It has similar config to `cs1`, but its executors have fewer threads. Limits total I/O of all compactions within the service to 40MB/s.
* Configure table `ci` to use compaction service `cs1` for system compactions and service `cs2` for user compactions.

```
config -s tserver.compaction.major.service.cs1.planner=org.apache.accumulo.core.spi.compaction.DefaultCompactionPlanner
config -s 'tserver.compaction.major.service.cs1.planner.opts.executors=[{"name":"small","type":"internal","maxSize":"16M","numThreads":8},{"name":"medium","type":"internal","maxSize":"128M","numThreads":4},{"name":"large","type":"internal","numThreads":2}]'
config -s tserver.compaction.major.service.cs2.planner=org.apache.accumulo.core.spi.compaction.DefaultCompactionPlanner
config -s 'tserver.compaction.major.service.cs2.planner.opts.executors=[{"name":"small","type":"internal","maxSize":"16M","numThreads":4},{"name":"medium","type":"internal","maxSize":"128M","numThreads":2},{"name":"large","type":"internal","numThreads":1}]'
config -s tserver.compaction.major.service.cs2.rate.limit=40M
config -t ci -s table.compaction.dispatcher=org.apache.accumulo.core.spi.compaction.SimpleCompactionDispatcher
config -t ci -s table.compaction.dispatcher.opts.service=cs1
config -t ci -s table.compaction.dispatcher.opts.service.user=cs2
```

For more information see the javadoc for {% jlink org.apache.accumulo.core.spi.compaction %},
{% jlink org.apache.accumulo.core.spi.compaction.DefaultCompactionPlanner %} and
{% jlink org.apache.accumulo.core.spi.compaction.SimpleCompactionDispatcher %}

The names of the compaction services and executors are used for logging and metrics.

## External Compactions

In Accumulo 2.1 we introduced a new optional feature that allows compactions to run
outside of the Tablet Server.  External compactions introduces two new server processes
in an Accumulo deployment:

  * *Compactor*: Accumulo process that runs external compactions and is started with the name of a queue for which it will perform compactions.  In a typical deployment there will be many of these processes running, some for queue A, queue B, etc.  This process will only run a single compaction at a time and will communicate with the Compaction Coordinator to get a compaction job and report its status.

  * *Compaction Coordinator*: a process that manages the compaction queues for all external compactions in the system and assigns compaction tasks to Compactors. In a typical deployment there will be one instance of this process in use at a time with a backup process waiting to become primary (much like the primary and secondary manager processes). This process communicates with the TabletServers to get external compaction job information and report back their status.

### Starting the Components

The CompactionCoordinator and Compactor components are started in the same manner as the other Accumulo services.

To start a CompactionCoordinator:

```
accumulo compaction-coordinator &
```

To start a Compactor:

```
accumulo compactor -q <queueName>
```

### Configuration

Configuration for external compactions is very similar to the internal compaction example above.
In the example below we create a Compaction Service `cs1` and configure it with a queue
named `DCQ1`. We then define the Compaction Dispatcher on table `testTable` and configure the
table to use the `cs1` Compaction Service for planning and executing all compactions.

```
config -s tserver.compaction.major.service.cs1.planner=org.apache.accumulo.core.spi.compaction.DefaultCompactionPlanner
config -s 'tserver.compaction.major.service.cs1.planner.opts.executors=[{"name":"all","type":"external","queue":"DCQ1"}]'
config -t testTable -s table.compaction.dispatcher=org.apache.accumulo.core.spi.compaction.SimpleCompactionDispatcher
config -t testTable -s table.compaction.dispatcher.opts.service=cs1
```

Note that you can mix internal and external options, for example:

```
config -s 'tserver.compaction.major.service.cs1.planner.opts.executors=[{"name":"small","type":"internal","maxSize":"16M","numThreads":8},{"name":"medium","type":"internal","maxSize":"128M","numThreads":4},{"name":"large","type":"external","queue":"LargeQ"}]'
```

### Overview

The CompactionCoordinator is responsible for managing the global external compaction work queue. For each external compaction queue, the tablet server will maintain an in memory priority queue of the tablets loaded on it that require external compactions. The coordinator polls all tservers to get summary information about their external compaction queues to combine the summary information to determine which tablet server to contact next to get work.  The coordinator does not maintain per tablet information, it only maintains enough information to allow it to know which tablet server to contact next for a given queue.  The tablet server will then know what specific tablet in that queue needs to compact.

When a Compactor is free to perform work, it asks the CompactionCoordinator for the next compaction job. The CompactionCoordinator contacts the next TabletServer that has the highest priority for the Compactor's queue. The TabletServer returns the information necessary for the compaction to occur to the CompactionCoordinator, which is passed on to the Compactor. The Compaction Coordinator maintains an in-memory list of running compactions and also inserts an entry into the metadata table for the tablet to denote that an external compaction is running. When the Compactor has finished the compaction, it notifies the CompactionCoordinator which inserts an entry into the metadata table to denote that the external compaction completed and it attempts to notify the TabletServer. If successful, the TabletServer commits the major compaction. If the TabletServer is down, or the Tablet has become hosted on a different TabletServer, then the CompactionCoordinator will fail to notify the TabletServer, but the metadata table entries will remain. The major compaction will be committed in the future by the TabletServer hosting the Tablet.

External compactions handle faults and major system events in Accumulo. When a compactor process dies this will be detected and any files it had reserved in a tablet will be unreserved.  When a tserver dies, this will not impact any external compactions running on behalf of tablets that tserver was hosting.  The case of tablets not being hosted on a tserver when an external compaction tries to commit is also handled.  Tablets being deleted (by split, merge, or table deletion) will cause any associated running external compactions to be canceled.  When a user initiated compaction is canceled, any external compactions running as part of that will be canceled.

### External Compaction in Action

Below are some examples of log entries and metadata table entries for external compactions. First, here are some metadata entries for table `2` . You can see that there are three files of different sizes (file size and number of entries are stored in the value portion of the metadata table rows with the "file" column qualifier).

```
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A0000047.rf []   12330,99000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F0000048.rf []   1196,1000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F000004j.rf []   1302,1000
2< last:10000bf4e0a0004 []  localhost:9997
2< loc:10000bf4e0a0004 []   localhost:9997
2< srv:compact []   111
2< srv:dir []   default_tablet
2< srv:flush [] 113
2< srv:lock []  tservers/localhost:9997/zlock#1950397a-b2ca-4685-b70b-67ae3cd578b9#0000000000$10000bf4e0a0004
2< srv:time []  M1618325648093
2< ~tab:~pr []  \x00
```

Below are excerpts from the TabletServer, CompactionCoordinator, Compactor logs and metadata table. I have merged the logs in time order to make it easier to see what is happening.

In the logs below the Compactor requested a compaction job from the Coordinator with an ExternalCompactionId of `de6afc1d-64ae-4abf-8bce-02ec0a79aa6c`. The Coordinator knew that TabletServer `localhost:9997` had a Tablet that needed compacting and contacted it to get the details. The CompactionManager, a component
running in the TabletServer, returned the information to the Coordinator. The Coordinator then updates the metadata table (below the logs) for the external compaction and returns the information to the Compactor:

```
2021-04-13T14:54:10,580 [compactor.Compactor] INFO : Attempting to get next job, eci = ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c
2021-04-13T14:54:10,580 [coordinator.CompactionCoordinator] DEBUG: getCompactionJob called for queue DCQ1 by compactor localhost:9101
2021-04-13T14:54:10,580 [coordinator.CompactionCoordinator] DEBUG: Found tserver localhost:9997 with priority 288230376151711747 compaction for queue DCQ1
2021-04-13T14:54:10,580 [coordinator.CompactionCoordinator] DEBUG: Getting compaction for queue DCQ1 from tserver localhost:9997
2021-04-13T14:54:10,581 [compactions.CompactionManager] DEBUG: Attempting to reserve external compaction, queue:DCQ1 priority:288230376151711747 compactor:localhost:9101
2021-04-13T14:54:10,596 [compactions.CompactionManager] DEBUG: Reserved external compaction ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c
2021-04-13T14:54:10,596 [coordinator.CompactionCoordinator] DEBUG: Returning external job ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c to localhost:9101
```

```
2< ecomp:ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c []   {"inputs":["hdfs://localhost:8020/accumulo/tables/2/default_tablet/F0000048.rf","hdfs://localhost:8020/accumulo/tables/2/default_tablet/A0000047.rf"],"tmp":"hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf_tmp","dest":"hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf","compactor":"localhost:9101","kind":"USER","executorId":"DCQ1","priority":288230376151711747}
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A0000047.rf []   12330,99000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F0000048.rf []   1196,1000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F000004j.rf []   1302,1000
2< last:10000bf4e0a0004 []  localhost:9997
2< loc:10000bf4e0a0004 []   localhost:9997
2< srv:compact []   111
2< srv:dir []   default_tablet
2< srv:flush [] 113
2< srv:lock []  tservers/localhost:9997/zlock#1950397a-b2ca-4685-b70b-67ae3cd578b9#0000000000$10000bf4e0a0004
2< srv:time []  M1618325648093
2< ~tab:~pr []  \x00
```

Next, the Compactor runs the compaction successfully and reports the status back to the Coordinator. The Coordinator inserts a final state marker into the metadata table (below the logs).

```
2021-04-13T14:54:11,597 [compactor.Compactor] INFO : Received next compaction job: TExternalCompactionJob(externalCompactionId:ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c, extent:TKeyExtent(table:32, endRow:null, prevEndRow:null), files:[In
putFile(metadataFileEntry:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F0000048.rf, size:0, entries:0, timestamp:0), InputFile(metadataFileEntry:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A0000047.rf, size:0, entries
:0, timestamp:0)], priority:3, readRate:0, writeRate:0, iteratorSettings:IteratorConfig(iterators:[]), type:FULL, reason:USER, outputFile:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf_tmp, propagateDeletes:false, kind
:USER)
2021-04-13T14:54:11,598 [compactor.Compactor] INFO : Starting up compaction runnable for job: TExternalCompactionJob(externalCompactionId:ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c, extent:TKeyExtent(table:32, endRow:null, prevEndRow:null)
, files:[InputFile(metadataFileEntry:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F0000048.rf, size:0, entries:0, timestamp:0), InputFile(metadataFileEntry:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A0000047.rf, size
:0, entries:0, timestamp:0)], priority:3, readRate:0, writeRate:0, iteratorSettings:IteratorConfig(iterators:[]), type:FULL, reason:USER, outputFile:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf_tmp, propagateDeletes:
false, kind:USER)
2021-04-13T14:54:11,599 [compactor.Compactor] INFO : CompactionCoordinator address is: localhost:9100
2021-04-13T14:54:11,599 [coordinator.CompactionCoordinator] INFO : Compaction status update, id: ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c, timestamp: 1618325651599, state: STARTED, message: Compaction started
2021-04-13T14:54:12,601 [compactor.Compactor] INFO : Starting compactor
2021-04-13T14:54:12,601 [compactor.Compactor] INFO : Progress checks will occur every 1 seconds
2021-04-13T14:54:12,718 [ratelimit.SharedRateLimiterFactory] DEBUG: RateLimiter 'read_rate_limiter': 69,672 of 0 permits/second
2021-04-13T14:54:12,718 [ratelimit.SharedRateLimiterFactory] DEBUG: RateLimiter 'write_rate_limiter': 45,120 of 0 permits/second
2021-04-13T14:54:13,179 [compactor.Compactor] INFO : Compaction completed successfully ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c
2021-04-13T14:54:13,180 [compactor.Compactor] INFO : CompactionCoordinator address is: localhost:9100
2021-04-13T14:54:13,181 [coordinator.CompactionCoordinator] INFO : Compaction status update, id: ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c, timestamp: 1618325653180, state: SUCCEEDED, message: Compaction completed successfully
2021-04-13T14:54:14,182 [compactor.Compactor] INFO : Compaction thread finished.
2021-04-13T14:54:14,182 [compactor.Compactor] INFO : Updating coordinator with compaction completion.
2021-04-13T14:54:14,184 [coordinator.CompactionCoordinator] INFO : Compaction completed, id: ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c, stats: CompactionStats(entriesRead:100000, entriesWritten:100000, fileSize:12354)
2021-04-13T14:54:14,185 [coordinator.CompactionFinalizer] INFO : Writing completed external compaction to metadata table: {"extent":{"tableId":"2"},"state":"FINISHED","fileSize":12354,"entries":100000}
2021-04-13T14:54:14,223 [coordinator.CompactionFinalizer] INFO : Queueing tserver notification for completed external compaction: {"extent":{"tableId":"2"},"state":"FINISHED","fileSize":12354,"entries":100000}
2021-04-13T14:54:14,290 [coordinator.CompactionFinalizer] INFO : Notifying tserver localhost:9997[10000bf4e0a0004] that compaction {"extent":{"tableId":"2"},"state":"FINISHED","fileSize":12354,"entries":100000} has finished.
```

```
2< ecomp:ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c []   {"inputs":["hdfs://localhost:8020/accumulo/tables/2/default_tablet/F0000048.rf","hdfs://localhost:8020/accumulo/tables/2/default_tablet/A0000047.rf"],"tmp":"hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf_tmp","dest":"hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf","compactor":"localhost:9101","kind":"USER","executorId":"DCQ1","priority":288230376151711747}
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A0000047.rf []   12330,99000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F0000048.rf []   1196,1000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F000004j.rf []   1302,1000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F000004l.rf []   841,1000
2< last:10000bf4e0a0004 []  localhost:9997
2< loc:10000bf4e0a0004 []   localhost:9997
2< srv:compact []   111
2< srv:dir []   default_tablet
2< srv:flush [] 114
2< srv:lock []  tservers/localhost:9997/zlock#1950397a-b2ca-4685-b70b-67ae3cd578b9#0000000000$10000bf4e0a0004
2< srv:time []  M1618325653080
2< ~tab:~pr []  \x00
~ecompECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c : []    {"extent":{"tableId":"2"},"state":"FINISHED","fileSize":12354,"entries":100000}
```

Finally, the TabletServer commits the compaction.

```
2021-04-13T14:54:14,290 [tablet.CompactableImpl] DEBUG: Attempting to commit external compaction ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c
2021-04-13T14:54:14,325 [tablet.files] DEBUG: Compacted 2<< for USER created hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf from [A0000047.rf, F0000048.rf]
2021-04-13T14:54:14,326 [tablet.CompactableImpl] DEBUG: Completed commit of external compaction ECID:de6afc1d-64ae-4abf-8bce-02ec0a79aa6c
```

```
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/A000004k.rf []   12354,100000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F000004j.rf []   1302,1000
2< file:hdfs://localhost:8020/accumulo/tables/2/default_tablet/F000004l.rf []   841,1000
2< last:10000bf4e0a0004 []  localhost:9997
2< loc:10000bf4e0a0004 []   localhost:9997
2< srv:compact []   112
2< srv:dir []   default_tablet
2< srv:flush [] 114
2< srv:lock []  tservers/localhost:9997/zlock#1950397a-b2ca-4685-b70b-67ae3cd578b9#0000000000$10000bf4e0a0004
2< srv:time []  M1618325653080
2< ~tab:~pr []  \x00
```

## Logging

The names of compaction services and executors are used in logging.  The log
messages below are from a tserver with the configuration above with data being
written to the ci table.  Also, a compaction of the table was forced from the
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



