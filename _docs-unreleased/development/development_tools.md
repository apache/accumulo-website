---
title: Development Tools
category: development
order: 3
---

Normally, Accumulo consists of lots of moving parts. Even a stand-alone version of
Accumulo requires Hadoop, Zookeeper, the Accumulo master, a tablet server, etc. If
you want to write a unit test that uses Accumulo, you need a lot of infrastructure
in place before your test can run.

## Mock Accumulo

Mock Accumulo supplies mock implementations for much of the client API. It presently
does not enforce users, logins, permissions, etc. It does support Iterators and Combiners.
Note that MockAccumulo holds all data in memory, and will not retain any data or
settings between runs.

While normal interaction with the Accumulo client looks like this:

```java
Instance instance = new ZooKeeperInstance(...);
Connector conn = instance.getConnector(user, passwordToken);
```

To interact with the MockAccumulo, just replace the ZooKeeperInstance with MockInstance:

```java
Instance instance = new MockInstance();
```

In fact, you can use the `--fake` option to the Accumulo shell and interact with
MockAccumulo:

```
$ accumulo shell --fake -u root -p ''

Shell - Apache Accumulo Interactive Shell
-
- version: 2.x.x
- instance name: fake
- instance id: mock-instance-id
-
- type 'help' for a list of available commands
-

root@fake> createtable test

root@fake test> insert row1 cf cq value
root@fake test> insert row2 cf cq value2
root@fake test> insert row3 cf cq value3

root@fake test> scan
row1 cf:cq []    value
row2 cf:cq []    value2
row3 cf:cq []    value3

root@fake test> scan -b row2 -e row2
row2 cf:cq []    value2

root@fake test>
```

When testing Map Reduce jobs, you can also set the Mock Accumulo on the AccumuloInputFormat
and AccumuloOutputFormat classes:

```java
// ... set up job configuration
AccumuloInputFormat.setMockInstance(job, "mockInstance");
AccumuloOutputFormat.setMockInstance(job, "mockInstance");
```

## Mini Accumulo Cluster

While the Mock Accumulo provides a lightweight implementation of the client API for unit
testing, it is often necessary to write more realistic end-to-end integration tests that
take advantage of the entire ecosystem. The Mini Accumulo Cluster makes this possible by
configuring and starting Zookeeper, initializing Accumulo, and starting the Master as well
as some Tablet Servers. It runs against the local filesystem instead of having to start
up HDFS.

To start it up, you will need to supply an empty directory and a root password as arguments:

```java
File tempDirectory = // JUnit and Guava supply mechanisms for creating temp directories
MiniAccumuloCluster accumulo = new MiniAccumuloCluster(tempDirectory, "password");
accumulo.start();
```

Once we have our mini cluster running, we will want to interact with the Accumulo client API:

```java
Instance instance = new ZooKeeperInstance(accumulo.getInstanceName(), accumulo.getZooKeepers());
Connector conn = instance.getConnector("root", new PasswordToken("password"));
```

Upon completion of our development code, we will want to shutdown our MiniAccumuloCluster:

```java
accumulo.stop();
// delete your temporary folder
```
