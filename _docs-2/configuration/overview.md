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

Accumulo services (i.e master, tablet server, monitor, etc) are configured by [server properties] whose values can be
set in the following locations (with increasing precedence):

1. Default values
2. [accumulo.properties] (overrides defaults)
3. Zookeeper (overrides [accumulo.properties] & defaults)

If a property is set in multiple locations, the value in the location with the highest precedence is used. 

The configuration locations above are described in detail below.

### Default values

All [server properties] have a default value. Default values are set in the source code and can be viewed for each property on the [server properties] page.
While default values have the lowest precedence, they are usually optimal.  However, there are cases where a change can increase query and ingest performance.

### accumulo.properties

Setting [server properties] in [accumulo.properties] will override their default value. If you are running Accumulo on a cluster, any updates to accumulo.properties must
be synced across the cluster. Accumulo processes (master, tserver, etc) read their local [accumulo.properties] on start up so processes must be restarted to apply changes.
Certain properties can only be set in accumulo.properties. These properties have **zk mutable: no** in their description. Setting properties in accumulo.properties allows you
to configure tablet servers with different settings.

### Zookeeper

Many [server properties] can be set in Zookeeper using the Accumulo API or shell. These properties can identified by **zk mutable: yes** in their description on
the [server properties] page. Zookeeper properties can be applied on a per-table or system-wide basis. Per-table properties take precedence over system-wide
properties. While most properties set in Zookeeper take effect immediately, some require a restart of the process which is indicated in **zk mutable** section
of their description.

#### Zookeeper System properties

System properties consist of all [server properties] with **zk mutable: yes** in their description. They are set with the following shell command:

    config -s PROPERTY=VALUE

If a {% plink table.* %} property is set using this method, the value will apply to all tables except those configured on per-table basis (which have higher precedence).

#### Zookeeper Table properties

Table properties consist of all properties with the {% plink table.* %} prefix.

Table properties are configured for a table namespace (i.e group of tables) or on a per-table basis.

To configure a table property for a namespace, use the following command:

    config -ns NAMESPACE -s PROPERTY=VALUE

To configure a table property for a specific table, use the following command:

    config -t TABLE -s PROPERTY=VALUE

Per-table settings take precedent over table namespace settings.  Both take precedent over system properties.

#### Zookeeper Considerations

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
[accumulo-client.properties]: {% durl configuration/files#accumulo-clientproperties %}
[accumulo.properties]: {% durl configuration/files#accumuloproperties %}
