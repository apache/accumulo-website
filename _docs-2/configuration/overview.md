---
title: Configuration Overview
category: configuration
order: 1
---

Configuration is managed differently for Accumulo clients and servers.

## Client Configuration

[Accumulo clients][accumulo-client] are created using Java builder methods, a Java properties object or an
[accumulo-client.properties] file containing [client properties].

## Server Configuration

Accumulo processes (i.e master, tablet server, monitor, etc) are configured by [server properties] whose values can be
set in the following configuration locations (with increasing precedence) that are described in detail below:

1. [Default](#default) - All properties have a default value
2. [Site](#site) - Properties set in [accumulo.properties]
3. [System](#system) - Properties set using shell or Java API that apply to entire Accumulo instance
4. [Namespace](#namespace) - Table properties set using shell or Java API that apply to a table namespace
5. [Table](#table) - Table properties set using shell or Java API that apply to a table.

If a property is set in multiple locations, the value in the location with the highest precedence is used.

These configuration locations are described in detail below:

### Default

All [server properties] have a default value. Default values are set in the source code and can be viewed for each property on the [server properties] page.
While default values have the lowest precedence, they are usually optimal.  However, there are cases where a change can increase query and ingest performance.

### Site

Site configuration refers to [server properties] set in the [accumulo.properties] file which can be found in the `conf/` directory. Site configuration will override the default value
of a property. If you are running Accumulo on a cluster, any updates to accumulo.properties must be synced across the cluster. Accumulo processes (master, tserver, etc) read their
local [accumulo.properties] on start up so processes must be restarted to apply changes. Certain properties can only be set in accumulo.properties. These properties have **zk mutable: no**
in their description. Setting properties in accumulo.properties allows you to configure tablet servers with different settings.

Site configuration can be overriden when starting an Accumulo process on the command line (by using the `-o` option):
```
accumulo tserver -o instance.secret=mysecret -o instance.zookeeper.host=localhost:2181
```
Overriding properties is useful if you can't change [accumulo.properties]. It's done when [running Accumulo using Docker](https://github.com/apache/accumulo-docker).

### System

System configuration refers to [server properties] set for the entire Accumulo instance/cluster. These settings are stored in ZooKeeper and can identified by **zk mutable: yes**
in their description on the [server properties] page. System configuration will override any site configuration set in [accumulo.properties]. While most system configuration
settings take effect immediately, some require a restart of the process which is indicated in the **zk mutable** section of their description. System configuration can be set using
the following shell command:

    config -s PROPERTY=VALUE

They can also be set using {% jlink org.apache.accumulo.core.client.admin.InstanceOperations %} in the Java API:

```java
client.instanceOperations().setProperty("table.durability", "flush");
```

### Namespace

Namespace configuration refers to [table.* properties] set for a certain table namespace (i.e group of tables). These settings are stored in ZooKeeper. Namespace configuration
will override System configuration and can be set using the following shell command:

    config -ns NAMESPACE -s PROPERTY=VALUE

It can also be set using {% jlink org.apache.accumulo.core.client.admin.NamespaceOperations %} in the Java API:

```java
client.namespaceOperations().setProperty("mynamespace", "table.durability", "sync");
```

### Table

Table configuration refers to [table.* properties] set for a certain table. These settings are stored in ZooKeeper and can be set using the following shell command:

    config -t TABLE -s PROPERTY=VALUE

They can also be set using {% jlink org.apache.accumulo.core.client.admin.TableOperations %} in the Java API:

```java
client.tableOperations().setProperty("mytable", "table.durability", "log");
```

### Zookeeper Considerations

Any [server properties] that are set in Zookeeper should consider the limitations of Zookeeper itself with respect to the
number of nodes and the size of the node data. Custom table properties and options for Iterators configured on tables
are two areas in which there aren't any fail safes built into the API that can prevent the user from making this mistake.

While these properties have the ability to add some much needed dynamic configuration tools, use cases which might fall
into these warnings should be reconsidered.

## Viewing Server Configuration

Accumulo's current configuration can be viewed in the shell using the `config` command.

* `config` - view configuration for the entire system
* `config -ns <NAMESPACE>` - view configuration for a specific namespace
* `config -t <TABLE>` - view configuration for a specific table

Below is example shell output from viewing configuration for the table `foo`. Please note how `table.compaction.major.ratio`
is set in multiple locations but the value `1.6` set in the `table` scope is used as it has the highest precedence.

```
root@accumulo-instance> config -t foo
---------+---------------------------------------------+-----------------------
SCOPE    | NAME                                        | VALUE
---------+---------------------------------------------+-----------------------
default  | table.bloom.enabled ....................... | false
default  | table.bloom.error.rate .................... | 0.5%
default  | table.bloom.hash.type ..................... | murmur
default  | table.bloom.load.threshold ................ | 1
default  | table.bloom.size .......................... | 1048576
default  | table.cache.block.enable .................. | false
default  | table.cache.index.enable .................. | false
default  | table.compaction.major.everything.at ...... | 19700101000000GMT
default  | table.compaction.major.everything.idle .... | 1h
default  | table.compaction.major.ratio .............. | 1.3
site     |    @override .............................. | 1.4
system   |    @override .............................. | 1.5
table    |    @override .............................. | 1.6
default  | table.compaction.minor.idle ............... | 5m
default  | table.compaction.minor.logs.threshold ..... | 3
default  | table.failures.ignore ..................... | false
```

[accumulo-client]: {% durl getting-started/clients#creating-an-accumulo-client %}
[client properties]: {% durl configuration/client-properties %}
[server properties]: {% durl configuration/server-properties %}
[table.* properties]: {% purl table.\* %}
[accumulo-client.properties]: {% durl configuration/files#accumulo-clientproperties %}
[accumulo.properties]: {% durl configuration/files#accumuloproperties %}
