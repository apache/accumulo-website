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

Starting with version 2.1.0, Accumulo uses [OpenTelemetry] to collect
and transport trace information to a back-end server that can display
the trace information. The Accumulo Trace server process and `trace` table
are no longer used. Also, the old `trace` configuration properties are now
deprecated and not used.

## Configuring Tracing

To collect traces, Accumulo needs two items:

 * [general.opentelemetry.enabled] must be set to `true`
 * The `io.opentelemetry.api.GlobalOpenTelemetry.globalOpenTelemetry` member variable must be set.

One way to set the `globalOpenTelemetry` member variable is to use the
OpenTelemetry Java [Agent]. Simply putting the agent jar on the classpath
and [configuring] that agent.

Hadoop is also working on using OpenTelemetry. This is being tracked at
https://issues.apache.org/jira/browse/HADOOP-15566.

## Instrumenting a Client

Accumulo client operations will be traced as part of a client application
operation if the client application is also instrumented using OpenTelemetry
and invokes the Accumulo client operation in a Span. Client application
developers can use the OpenTelemetry [documentation] to instrument the
application. To collect traces in the client, Accumulo needs the
`io.opentelemetry.api.GlobalOpenTelemetry.globalOpenTelemetry` member
variable set to an OpenTelemetry instance.

### Tracing from the Shell
You can enable tracing for operations run from the shell by using the
`trace on` and `trace off` commands.

[config-mgmt]: {% durl configuration/overview %}
[Agent]: https://github.com/open-telemetry/opentelemetry-java-instrumentation
[configuring]: https://github.com/open-telemetry/opentelemetry-java-instrumentation/blob/main/docs/agent-config.md
[documentation]: https://opentelemetry.io/docs/instrumentation/java/manual_instrumentation/#tracing
[OpenTelemetry]: https://opentelemetry.io/
[general.opentelemetry.enabled]: {% purl general.opentelemetry.enabled %}
