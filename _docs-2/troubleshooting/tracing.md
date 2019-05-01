---
title: Tracing
category: troubleshooting
order: 6
---

It can be difficult to determine why some operations are taking longer
than expected. For example, you may be looking up items with very low
latency, but sometimes the lookups take much longer. Determining the
cause of the delay is difficult because the system is distributed, and
the typical lookup is fast.

Accumulo has been instrumented to record the time that various
operations take when tracing is turned on. The fact that tracing is
enabled follows all the requests made on behalf of the user throughout
the distributed infrastructure of accumulo, and across all threads of
execution.

These time spans will be inserted into the `trace` table in
Accumulo. You can browse recent traces from the Accumulo monitor
page. You can also read the `trace` table directly like any
other table.

The design of Accumulo's distributed tracing follows that of [Google's Dapper](http://research.google.com/pubs/pub36356.html).

## Tracers

To collect traces, Accumulo needs at least one tracer server running. If you are using `accumulo-cluster` to start your cluster,
configure your server in `conf/tracers`. The server collects traces from clients and writes them to the `trace` table. The Accumulo
user that the tracer connects to Accumulo with can be configured with the following properties (see the [configuration overview][config-mgmt] 
page for setting Accumulo server properties)

 * [trace.user]
 * [trace.token.property.password]

Other tracer configuration properties include

 * [trace.port.client] - port tracer listens on
 * [trace.table] - table tracer writes to
 * [trace.zookeeper.path] - zookeeper path where tracers register

The zookeeper path is configured to /tracers by default.  If
multiple Accumulo instances are sharing the same ZooKeeper
quorum, take care to configure Accumulo with unique values for
this property.

## Configuring Tracing

Traces are collected via SpanReceivers. The default SpanReceiver
configured is org.apache.accumulo.core.trace.ZooTraceClient, which
sends spans to an Accumulo Tracer process, as discussed in the
previous section. This default can be changed to a different span
receiver, or additional span receivers can be added in a
comma-separated list, by modifying the property [trace.span.receivers].

Individual span receivers may require their own configuration
parameters, which are grouped under the [trace.span.receiver.*]
prefix.  ZooTraceClient uses the following properties.  The first
three properties are populated from other Accumulo properties,
while the remaining ones should be prefixed with
trace.span.receiver. when set in the Accumulo configuration.

    tracer.zookeeper.host - populated from instance.zookeepers
    tracer.zookeeper.timeout - populated from instance.zookeeper.timeout
    tracer.zookeeper.path - populated from trace.zookeeper.path
    tracer.send.timer.millis - timer for flushing send queue (in ms, default 1000)
    tracer.queue.size - max queue size (default 5000)
    tracer.span.min.ms - minimum span length to store (in ms, default 1)

To configure an Accumulo client for tracing, set {% plink -c trace.span.receivers %} and {% plink -c trace.zookeeper.path %}
in `accumulo-client.properties`. Also, any [trace.span.receiver.*] properties set in `accumulo.properties` should be set in
`accumulo-client.properties`.

Hadoop can also be configured to send traces to Accumulo, as of
Hadoop 2.6.0, by setting properties in Hadoop's core-site.xml
file.  Instead of using the [trace.span.receiver.*] prefix, Hadoop
uses hadoop.htrace.*.  The Hadoop configuration does not have
access to Accumulo's properties, so the
hadoop.htrace.tracer.zookeeper.host property must be specified.
The zookeeper timeout defaults to 30000 (30 seconds), and the
zookeeper path defaults to /tracers.  An example of configuring
Hadoop to send traces to ZooTraceClient is

```xml
<property>
  <name>hadoop.htrace.spanreceiver.classes</name>
  <value>org.apache.accumulo.core.trace.ZooTraceClient</value>
</property>
<property>
  <name>hadoop.htrace.tracer.zookeeper.host</name>
  <value>zookeeperHost:2181</value>
</property>
<property>
  <name>hadoop.htrace.tracer.zookeeper.path</name>
  <value>/tracers</value>
</property>
<property>
  <name>hadoop.htrace.tracer.span.min.ms</name>
  <value>1</value>
</property>
```

The accumulo-core, accumulo-tracer, accumulo-fate and libthrift
jars must also be placed on Hadoop's classpath.

### Adding additional SpanReceivers

[Zipkin] has a SpanReceiver supported by HTrace and popularized by Twitter
that users looking for a more graphical trace display may opt to use.
The following steps configure Accumulo to use `org.apache.htrace.impl.ZipkinSpanReceiver`
in addition to the Accumulo's default ZooTraceClient, and they serve as a template
for adding any SpanReceiver to Accumulo:

1. Add the Jar containing the ZipkinSpanReceiver class file to the
`lib/` directory.  It is critical that the Jar is placed in
`lib/` and NOT in `lib/ext/` so that the new SpanReceiver class
is visible to the same class loader of htrace-core.

2. Add the following to `accumulo.properties`:

        trace.span.receivers=org.apache.accumulo.tracer.ZooTraceClient,org.apache.htrace.impl.ZipkinSpanReceiver

3. Restart your Accumulo tablet servers.

In order to use ZipkinSpanReceiver from a client as well as the Accumulo server,

1. Ensure your client can see the ZipkinSpanReceiver class at runtime. For Maven projects,
this is easily done by adding to your client's pom.xml (taking care to specify a good version)

        <dependency>
          <groupId>org.apache.htrace</groupId>
          <artifactId>htrace-zipkin</artifactId>
          <version>3.1.0-incubating</version>
          <scope>runtime</scope>
        </dependency>

2. Add the following to your `accumulo-client.properties`.

        trace.span.receivers=org.apache.accumulo.tracer.ZooTraceClient,org.apache.htrace.impl.ZipkinSpanReceiver

3. Instrument your client as in the next section.

Your SpanReceiver may require additional properties, and if so these should likewise
be placed in `accumulo-client.properties` (if applicable) and Accumulo's `accumulo.properties`.
Two such properties for ZipkinSpanReceiver, listed with their default values, are

```
trace.span.receiver.zipkin.collector-hostname=localhost
trace.span.receiver.zipkin.collector-port=9410
```

### Instrumenting a Client

Tracing can be used to measure a client operation, such as a scan, as
the operation traverses the distributed system. To enable tracing for
your application call

```java
import org.apache.accumulo.core.trace.DistributedTrace;
...
DistributedTrace.enable(hostname, "myApplication");
// do some tracing
...
DistributedTrace.disable();
```

Once tracing has been enabled, a client can wrap an operation in a trace.

```java
import org.apache.htrace.Sampler;
import org.apache.htrace.Trace;
import org.apache.htrace.TraceScope;
...
TraceScope scope = Trace.startSpan("Client Scan", Sampler.ALWAYS);
BatchScanner scanner = client.createBatchScanner(...);
// Configure your scanner
for (Entry entry : scanner) {
}
scope.close();
```

The user can create additional Spans within a Trace.

The sampler (such as `Sampler.ALWAYS`) for the trace should only be specified with a top-level span,
and subsequent spans will be collected depending on whether that first span was sampled.
Don't forget to specify a Sampler at the top-level span
because the default Sampler only samples when part of a pre-existing trace,
which will never occur in a client that never specifies a Sampler.

```java
TraceScope scope = Trace.startSpan("Client Update", Sampler.ALWAYS);
...
TraceScope readScope = Trace.startSpan("Read");
...
readScope.close();
...
TraceScope writeScope = Trace.startSpan("Write");
...
writeScope.close();
scope.close();
```

Like Dapper, Accumulo tracing supports user defined annotations to associate additional data with a Trace.
Checking whether currently tracing is necessary when using a sampler other than Sampler.ALWAYS.

```java
...
int numberOfEntriesRead = 0;
TraceScope readScope = Trace.startSpan("Read");
// Do the read, update the counter
...
if (Trace.isTracing)
  readScope.getSpan().addKVAnnotation("Number of Entries Read".getBytes(StandardCharsets.UTF_8),
      String.valueOf(numberOfEntriesRead).getBytes(StandardCharsets.UTF_8));
```

It is also possible to add timeline annotations to your spans.
This associates a string with a given timestamp between the start and stop times for a span.

```java
...
writeScope.getSpan().addTimelineAnnotation("Initiating Flush");
```

Some client operations may have a high volume within your
application. As such, you may wish to only sample a percentage of
operations for tracing. As seen below, the CountSampler can be used to
help enable tracing for 1-in-1000 operations

```java
import org.apache.htrace.impl.CountSampler;
...
Sampler sampler = new CountSampler(HTraceConfiguration.fromMap(
    Collections.singletonMap(CountSampler.SAMPLER_FREQUENCY_CONF_KEY, "1000")));
...
TraceScope readScope = Trace.startSpan("Read", sampler);
...
readScope.close();
```

Remember to close all spans and disable tracing when finished.

```java
DistributedTrace.disable();
```

## Viewing Collected Traces

To view collected traces, use the "Recent Traces" link on the Monitor
UI. You can also programmatically access and print traces using the
`TraceDump` class.

### Trace Table Format

This section is for developers looking to use data recorded in the trace table
directly, above and beyond the default services of the Accumulo monitor.
Please note the trace table format and its supporting classes
are not in the public API and may be subject to change in future versions.

Each span received by a tracer's ZooTraceClient is recorded in the trace table
in the form of three entries: span entries, index entries, and start time entries.
Span and start time entries record full span information,
whereas index entries provide indexing into span information
useful for quickly finding spans by type or start time.

Each entry is illustrated by a description and sample of data.
In the description, a token in quotes is a String literal,
whereas other other tokens are span variables.
Parentheses group parts together, to distinguish colon characters inside the
column family or qualifier from the colon that separates column family and qualifier.
We use the format `row columnFamily:columnQualifier columnVisibility    value`
(omitting timestamp which records the time an entry is written to the trace table).

Span entries take the following form:

    traceId        "span":(parentSpanId:spanId)            []    spanBinaryEncoding
    63b318de80de96d1 span:4b8f66077df89de1:3778c6739afe4e1 []    %18;%09;...

The parentSpanId is "" for the root span of a trace.
The spanBinaryEncoding is a compact Apache Thrift encoding of the original Span object.
This allows clients (and the Accumulo monitor) to recover all the details of the original Span
at a later time, by scanning the trace table and decoding the value of span entries
via `TraceFormatter.getRemoteSpan(entry)`.

The trace table has a formatter class by default (org.apache.accumulo.tracer.TraceFormatter)
that changes how span entries appear from the Accumulo shell.
Normal scans to the trace table do not use this formatter representation;
it exists only to make span entries easier to view inside the Accumulo shell.

Index entries take the following form:

    "idx":service:startTime description:sender  []    traceId:elapsedTime
    idx:tserver:14f3828f58b startScan:localhost []    63b318de80de96d1:1

The service and sender are set by the first call of each Accumulo process
(and instrumented client processes) to `DistributedTrace.enable(...)`
(the sender is autodetected if not specified).
The description is specified in each span.
Start time and the elapsed time (start - stop, 1 millisecond in the example above)
are recorded in milliseconds as long values serialized to a string in hex.

Start time entries take the following form:

    "start":startTime "id":traceId        []    spanBinaryEncoding
    start:14f3828a351 id:63b318de80de96d1 []    %18;%09;...

The following classes may be run while Accumulo is running to provide insight into trace statistics. These require
accumulo-trace-VERSION.jar to be provided on the Accumulo classpath (`lib/ext` is fine).

    $ accumulo org.apache.accumulo.tracer.TraceTableStats -u username -p password -i instancename
    $ accumulo org.apache.accumulo.tracer.TraceDump -u username -p password -i instancename -r

### Tracing from the Shell
You can enable tracing for operations run from the shell by using the
`trace on` and `trace off` commands.

```
root@test test> trace on

root@test test> scan
a b:c []    d

root@test test> trace off
Waiting for trace information
Waiting for trace information
Trace started at 2013/08/26 13:24:08.332
Time  Start  Service@Location       Name
 3628+0      shell@localhost shell:root
    8+1690     shell@localhost scan
    7+1691       shell@localhost scan:location
    6+1692         tserver@localhost startScan
    5+1692           tserver@localhost tablet read ahead 6
```

[config-mgmt]: {% durl configuration/overview %}
[Zipkin]: https://github.com/openzipkin/zipkin
[trace.user]: {% purl trace.user %}
[trace.token.property.password]: {% purl trace.token.property.password %}
[trace.port.client]: {% purl trace.port.client %}
[trace.table]: {% purl trace.table %}
[trace.zookeeper.path]: {% purl trace.zookeeper.path %}
[trace.span.receivers]: {% purl trace.span.receivers %}
[trace.span.receiver.*]: {% purl trace.span.receiver.\* %}
