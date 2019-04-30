---
title: Configuration Files
category: configuration
order: 2
---

Accumulo has the following configuration files which can be found in the
`conf/` directory of the Accumulo release tarball.

## accumulo.properties

The {% ghc assemble/conf/accumulo.properties %} file configures Accumulo server processes using
[server properties]({% durl configuration/server-properties %}). This file can be found in the `conf/`
direcory. It is needed on every host that runs Accumulo processes. Therfore, any configuration should be
replicated to all hosts of the Accumulo cluster. If a property is not configured here, it might have been
[configured another way]({% durl configuration/overview %}).  See the [quick start] for help with
configuring this file.

## accumulo-client.properties

The `accumulo-client.properties` file configures Accumulo client processes using
[client properties]({% durl configuration/client-properties %}). If `accumulo shell` is run without arguments,
the Accumulo connection information in this file will be used. This file can be used to create an AccumuloClient
in Java using the following code:

```java
AccumuloClient client = Accumulo.newClient()
                           .from("/path/to/accumulo-client.properties").build();
```

See the [quick start] for help with configuring this file.

## accumulo-env.sh

The {% ghc assemble/conf/accumulo-env.sh %} file configures the Java classpath and JVM options needed to run
Accumulo processes. See the [quick install] for help with configuring this file.

## Log configuration files

### log4j-service.properties

The {% ghc assemble/conf/log4j-service.properties %} file configures logging for most Accumulo services
(i.e [Master], [Tablet Server], [Garbage Collector]) except for the Monitor.

### log4j-monitor.properties

The {% ghc assemble/conf/log4j-monitor.properties %} file configures logging for the [Monitor].

### log4j.properties

The {% ghc assemble/conf/log4j.properties %} file configures logging for Accumulo commands (i.e `accumulo init`,
`accumulo shell`, etc).

## Host files

The `accumulo-cluster` script uses the host files below to determine where Accumulo processes should be run.
These files are not in `conf/` directory the Accumulo release tarball by default. They can be created by running
the command `accumulo-cluster create-config`.

### gc

Contains a list of hosts where [Garbage Collector] processes should run. While only one host is needed, others can be specified
to run standby Garbage Collectors that can take over if the lead Garbage Collector fails.

### masters

Contains a list of hosts where [Master] processes should run. While only one host needed, others can be specified
to run on standby Masters that can take over if the lead Master fails.

### monitor

Contains a list of hosts where [Monitor] processes should run. While only one host is needed, others can be specified
to run standby Monitors that can take over if the lead Monitor fails.

### tservers

Contains list of hosts where [Tablet Server] processes should run. While only one host is needed, it is recommended that
multiple tablet servers are run for improved fault tolerance and peformance.

### tracers

Contains a list of hosts where [Tracer] processes should run. While only one host is needed, others can be specified
to run standby Tracers that can take over if the lead Tracer fails.

[Garbage Collector]: {% durl getting-started/design#garbage-collector %}
[Master]: {% durl getting-started/design#master %}
[Tablet Server]: {% durl getting-started/design#tablet-server %}
[Monitor]: {% durl getting-started/design#monitor %}
[Tracer]: {% durl getting-started/design#tracer %}
[quick start]: {% durl getting-started/quickstart#configuring-accumulo %}
