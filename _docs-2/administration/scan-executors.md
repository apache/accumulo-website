---
title: Scan Executors
category: administration
order: 8
---

Accumulo scans operate by repeatedly fetching batches of data from a [tablet
server][tserver].  On the tablet server side, a thread pool fetches batches.
In Java threads pools are called executors.  By default, a single executor per
tablet server handles all scans in FIFO order.  For some workloads, the single
FIFO executor is suboptimal.  For example, consider many unimportant scans
reading lots of data mixed with a few important scans reading small amounts of
data.  The long scans noticeably increase the latency of the short scans.
Accumulo offers two mechanisms to help improve situations like this: multiple
scan executors and per executor prioritizers.  Additional scan executors can
give tables dedicated resources.  For each scan executor, an optional
prioritizer can reorder queued work.

### Configuring and using Scan Executors

By default, Accumulo sets `tserver.scan.executors.default.threads=16` which
creates the default scan executor.  To configure additional scan executors,
chose a unique name and configure {% plink tserver.scan.executors.\* %}.  Setting
the following causes each tablet server to create a scan executor with the
specified threads.

```
tserver.scan.executors.<name>.threads=<number>
```

Optionally, some of the following can be set.  The `priority` setting
determines thread priority.  The `prioritizer` settings specifies a class that
orders pending work.

```
tserver.scan.executors.<name>.priority=<number 1 to 10>
tserver.scan.executors.<name>.prioritizer=<class name>
tserver.scan.executors.<name>.prioritizer.opts.<key>=<value>
```

After creating an executor, configure {% plink table.scan.dispatcher %} to use it.  A
dispatcher is Java subclass of {%jlink org.apache.accumulo.core.spi.scan.ScanDispatcher %}
that decides which scan executor should service a table.  Set the following table
property to configure a dispatcher.

```
table.scan.dispatcher=<class name>
```

Scan dispatcher options can be set with properties like the following.

```
table.scan.dispatcher.opts.<key>=<value>
```

The default value for `table.scan.dispatcher` is {% jlink org.apache.accumulo.core.spi.scan.SimpleScanDispatcher %}.
SimpleScanDispatcher supports an `executor` option for choosing a scan
executor.  If this option is not set, then SimpleScanDispatcher will dispatch
to the scan executor named `default`.

To to tie everything together, consider the following use case.

 * Create tables named LOW1 and LOW2 using a scan executor with a single thread.
 * Create a table named HIGH with a dedicated scan executor with 8 threads.
 * Create tables named NORM1 and NORM2 using the default scan executor.
 * Set the default executor to 4 threads.

The following shell commands implement this use case.

```
createtable LOW1
createtable LOW2
createtable HIGH
createtable NORM1
createtable NORM2
config -s tserver.scan.executors.default.threads=4
config -s tserver.scan.executors.low.threads=1
config -s tserver.scan.executors.high.threads=8
```

Tablet servers should be restarted after configuring scan executors, then tables can be configured.

```
config -t LOW1 -s table.scan.dispatcher=org.apache.accumulo.core.spi.scan.SimpleScanDispatcher
config -t LOW1 -s table.scan.dispatcher.opts.executor=low
config -t LOW2 -s table.scan.dispatcher=org.apache.accumulo.core.spi.scan.SimpleScanDispatcher
config -t LOW2 -s table.scan.dispatcher.opts.executor=low
config -t HIGH -s table.scan.dispatcher=org.apache.accumulo.core.spi.scan.SimpleScanDispatcher
config -t HIGH -s table.scan.dispatcher.opts.executor=high
```

While not necessary because its the default, it is safer to also set
`table.scan.dispatcher=org.apache.accumulo.core.spi.scan.SimpleScanDispatcher`
for each table.  This ensures things work as expected in the case where
`table.scan.dispatcher` was set at the system or namespace level.

### Configuring and using Scan Prioritizers.

When all scan executor threads are busy, incoming work is queued.  By
default this queue has a FIFO order.  A {% jlink org.apache.accumulo.core.spi.scan.ScanPrioritizer %} can be configured to
reorder the queue.  Accumulo ships with the {% jlink org.apache.accumulo.core.spi.scan.IdleRatioScanPrioritizer %} which
orders the queue by the ratio of run time to idle time.  For example, a scan
with a run time of 50ms and an idle time of 200ms would have a ratio of .25.
If .25 were the lowest ratio on the queue, then it would be the next in line.
The following configures the IdleRatioScanPrioritizer for the `default` scan
executor.

```
tserver.scan.executors.default.prioritizer=org.apache.accumulo.core.spi.scan.IdleRatioScanPrioritizer
```

Using the IdleRatioScanPrioritizer in a test with 50 long running scans and 5
threads repeatedly doing small random lookups made a significant difference.
In this test the average lookup time for the 5 threads went from 250ms to 5 ms.

### Providing hints from the client side.

Scanners can provide hints to ScanDispatchers and ScanPriotizers by calling
[setExecutionHints] on the Scanner.  What, if anything, is done with these
hints depends on what is configured for the table and system.  Accumulo's
default configuration ignores hints. The following shell commands make it
possible to choose an executor and set priorities from a scanner for the
table `tex`.

```
config -s tserver.scan.executors.special.threads=8
config -s tserver.scan.executors.special.prioritizer=org.apache.accumulo.core.spi.scan.HintScanPrioritizer
config -s tserver.scan.executors.special.prioritizer.opts.priority.alpha=1
config -s tserver.scan.executors.special.prioritizer.opts.priority.gamma=3
createtable tex
config -t tex -s table.scan.dispatcher=org.apache.accumulo.core.spi.scan.SimpleScanDispatcher
config -t tex -s table.scan.dispatcher.opts.executor.alpha=special
config -t tex -s table.scan.dispatcher.opts.executor.gamma=special
```

The {% jlink org.apache.accumulo.core.spi.scan.HintScanPrioritizer %} honors
hints of the form `priority=<integer>` or `scan_type=<type>` to prioritize
scans, with lower integers resulting in a higher priority.  When a hint
specifies a scan type it is mapped to a priority based on the prioritizer
configuration.

The `SimpleScanDispatcher`, which is the default dispatcher, supports
`executor.<type>=<executor>` options. When a scanner sets a hint of the form
`scan_type=<type>` it will use the executor configured for that type. 

After restarting tservers, the following command will start a scan that uses
the executor `special` with a priority of 3.  The scan dispatcher maps the scan
type `gamma` to the executor `special`.  The prioritizer maps the scan type
`gamma` to a priority of 3.

```
scan -t tex --execution-hints scan_type=gamma
```

The following command will start a scan that uses the executor `special` with a
priority of 1.

```
scan -t tex --execution-hints scan_type=alpha
```

[tserver]: {{ page.docs_baseurl }}/getting-started/design#tablet-server-1
[setExecutionHints]: {% jurl org.apache.accumulo.core.client.ScannerBase#setExecutionHints-java.util.Map- %}

