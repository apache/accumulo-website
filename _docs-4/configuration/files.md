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
directory. It is needed on every host that runs Accumulo processes. Therefore, any configuration should be
replicated to all hosts of the Accumulo cluster. If a property is not configured here, it might have been
[configured another way]({% durl configuration/overview %}).  See the [quick start] for help with
configuring this file.

## accumulo-client.properties

The `accumulo-client.properties` file configures Accumulo client processes using
[client properties]({% durl configuration/client-properties %}). If `accumulo shell` is run without arguments,
the Accumulo connection information in this file will be used. This file can be used to create an AccumuloClient
in Java using the following code:

```java
AccumuloClient client = Accumulo.newClient().from("/path/to/accumulo-client.properties").build();
```

See the [quick start] for help with configuring this file.

## accumulo-env.sh

The {% ghc assemble/conf/accumulo-env.sh %} file configures the Java classpath and JVM options needed to run
Accumulo processes. See the [quick start] for help with configuring this file.

## Log configuration files

### log4j2-service.properties

Since 2.1, the {% ghc assemble/conf/log4j2-service.properties %} file configures logging for most Accumulo services
(i.e [Manager], [Tablet Server], [Garbage Collector], [Monitor]). Prior to 2.1 this file was named `log4j-service.properties`
and did not apply to the [Monitor] which was configured in a separate `log4j-monitor.properties`.

### log4j2.properties

The {% ghc assemble/conf/log4j2.properties %} file configures logging for Accumulo commands (i.e `accumulo init`,
`accumulo shell`, etc).

## cluster.yaml

The `accumulo-cluster` script uses the `cluster.yaml` file to determine where Accumulo processes should be run.
This file is not in the `conf/` directory of the Accumulo release tarball by default. It can be created by running
the command `accumulo-cluster create-config`. The `cluster.yaml` file contains the following sections:

### gc

Contains a list of hosts where [Garbage Collector] processes should run. While only one host is needed, others can be specified
to run standby Garbage Collectors that can take over if the lead Garbage Collector fails.

### manager

Contains a list of hosts where [Manager] processes should run. While only one host is needed, others can be specified
to run on standby Managers that can take over if the lead Manager fails.

### monitor

Contains a list of hosts where [Monitor] processes should run. While only one host is needed, others can be specified
to run standby Monitors that can take over if the lead Monitor fails.

### tserver

Contains list of hosts where [Tablet Server] processes should run. While only one host is needed, it is recommended that
multiple tablet servers are run for improved fault tolerance and performance.

### sserver

Contains a list of hosts where [ScanServer] processes should run. While only one host is needed, it is recommended
that multiple ScanServers are run for improved performance.

### compaction coordinator

Contains a list of hosts where [CompactionCoordinator] processes should run. While only one host is needed,
others can be specified to run standby CompactionCoordinators that can take over if the lead CompactionCoordinator fails.

### compaction compactor

Contains a list of hosts where [Compactor] processes should run. While only one host is needed, it is recommended that
multiple Compactors are run for improved external compaction performance.

[Garbage Collector]: {% durl getting-started/design#garbage-collector %}
[Manager]: {% durl getting-started/design#manager %}
[Tablet Server]: {% durl getting-started/design#tablet-server %}
[Monitor]: {% durl getting-started/design#monitor %}
[CompactionCoordinator]: {% durl getting-started/design#compaction-coordinator-experimental %}
[Compactor]: {% durl getting-started/design#compactor-experimental %}
[ScanServer]: {% durl getting-started/design#scan-server-experimental %}
[quick start]: {% durl getting-started/quickstart#configuring-accumulo %}
