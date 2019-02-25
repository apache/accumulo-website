---
title: Accumulo Clients
category: getting-started
order: 4
---

## Creating Client Code

If you are using Maven to create Accumulo client code, add the following dependency to your pom:

```xml
<dependency>
  <groupId>org.apache.accumulo</groupId>
  <artifactId>accumulo-core</artifactId>
  <version>{{ page.latest_release }}</version>
</dependency>
```

When writing code that uses Accumulo, only use the [Accumulo Public API](/api).
The `accumulo-core` artifact includes implementation code that falls outside the
Public API and should be avoided.

## Creating an Accumulo Client

Before creating an Accumulo client, you will need the following information:

 * Accumulo instance name
 * Zookeeper connection string
 * Accumulo username & password

The [AccumuloClient] object is the main entry point for Accumulo clients. It can be created using one
of the following methods:

1. Using the [accumulo-client.properties] file (a template can be found in the `conf/` directory
   of the tarball distribution):
    ```java
    AccumuloClient client = Accumulo.newClient()
                              .from("/path/to/accumulo-client.properties").build();
    ```
1. Using the builder methods of [AccumuloClient]:
    ```java
    AccumuloClient client = Accumulo.newClient()
                              .to("myinstance", "zookeeper1,zookeeper2")
                              .as("myuser", "mypassword").build();
    ```
1. Using a Java Properties object.
    ```java
    Properties props = new Properties()
    props.put("instance.name", "myinstance")
    props.put("instance.zookeepers", "zookeeper1,zookeeper2")
    props.put("auth.type", "password")
    props.put("auth.principal", "myuser")
    props.put("auth.token", "mypassword")
    AccumuloClient client = Accumulo.newClient().from(props).build();
    ```

If an [accumulo-client.properties] file or a Java Properties object is used to create a [AccumuloClient], the following
[client properties][client-props] must be set:

* [instance.name] - Name of Accumulo instance to connect to
* [instance.zookeepers] - ZooKeeper connection information for this Accumulo instance
* [auth.type] - Authentication method. Possible values are `password`, `kerberos`, or authentication token class (i.e `PasswordToken`, `org.apache.accumulo.core.client.security.tokens.PasswordToken`)
* [auth.principal] - Accumulo principal/username
* [auth.token] - Token associated with `auth.type`. See table for mapping below:

| auth.type       | expected auth.token     | example auth.token   |
|-----------------|-------------------------|----------------------|
| password        | Password string         | mypassword           |
| kerberos        | Path to Kerberos keytab | /path/to/keytab      |
| Authentication token class | Base64 encoded token    | AAAAGh+LCAAAAAAAAAArTk0uSi0BAOXoolwGAAAA |

If a token class is used for `auth.type`, you can create create a Base64 encoded token using the `accumulo create-token` command.

```
$ accumulo create-token
Username (aka principal): root
the password for the principal: ******
auth.type = org.apache.accumulo.core.client.security.tokens.PasswordToken
auth.principal = root
auth.token = AAAAGh+LCAAAAAAAAAArTk0uSi0BAOXoolwGAAAA
```

# Authentication

When creating a [AccumuloClient], the user must be authenticated using one of the following
implementations of [AuthenticationToken] below:

1. [PasswordToken] is the must commonly used implementation.
1. [CredentialProviderToken] leverages the Hadoop CredentialProviders (new in Hadoop 2.6).
   For example, the [CredentialProviderToken] can be used in conjunction with a Java KeyStore to
   alleviate passwords stored in cleartext. When stored in HDFS, a single KeyStore can be used across
   an entire instance. Be aware that KeyStores stored on the local filesystem must be made available
   to all nodes in the Accumulo cluster.
1. [KerberosToken] can be provided to use the authentication provided by Kerberos. Using Kerberos
   requires external setup and additional configuration, but provides a single point of authentication
   through HDFS, YARN and ZooKeeper and allowing for password-less authentication with Accumulo.

    ```java
    KerberosToken token = new KerberosToken();
    AccumuloClient client = Accumulo.newClient().to("myinstance", "zookeeper1,zookeper2")
                              .as(token.getPrincipal(), token).build();
    ```

## Writing Data

With a [AccumuloClient] created, it can be used to create objects (like the [BatchWriter]) for
reading and writing from Accumulo:

```java
BatchWriter writer = client.createBatchWriter("table");
```

Data is written to Accumulo by creating [Mutation] objects that represent all the
changes to the columns of a single row. The changes are made atomically in the
TabletServer. Clients then add Mutations to a [BatchWriter] which submits them to
the appropriate TabletServers.

The code below shows how a Mutation is created.

```java
Mutation mutation = new Mutation("row1");
mutation.at().family("myColFam1").qualifier("myColQual1").visibility("public").put("myValue1");
mutation.at().family("myColFam2").qualifier("myColQual2").visibility("public").put("myValue2");
```

### BatchWriter

The [BatchWriter] is highly optimized to send Mutations to multiple TabletServers
and automatically batches Mutations destined for the same TabletServer to
amortize network overhead. Care must be taken to avoid changing the contents of
any Object passed to the BatchWriter since it keeps objects in memory while
batching.

The code below shows how a Mutation is added to a BatchWriter:

```java
try (BatchWriter writer = client.createBatchWriter("mytable")) {
  Mutation m = new Mutation("row1");
  m.at().family("myfam").qualifier("myqual").visibility("public").put("myval");
  writer.addMutation(m);
}
```

For more example code, see the [batch writing and scanning example][batch].

### ConditionalWriter

The [ConditionalWriter] enables efficient, atomic read-modify-write operations on
rows.  The ConditionalWriter writes special Mutations which have a list of per
column conditions that must all be met before the mutation is applied.  The
conditions are checked in the tablet server while a row lock is
held (Mutations written by the [BatchWriter] will not obtain a row
lock).  The conditions that can be checked for a column are equality and
absence.  For example a conditional mutation can require that column A is
absent inorder to be applied.  Iterators can be applied when checking
conditions.  Using iterators, many other operations besides equality and
absence can be checked.  For example, using an iterator that converts values
less than 5 to 0 and everything else to 1, its possible to only apply a
mutation when a column is less than 5.

In the case when a tablet server dies after a client sent a conditional
mutation, its not known if the mutation was applied or not.  When this happens
the [ConditionalWriter] reports a status of UNKNOWN for the ConditionalMutation.
In many cases this situation can be dealt with by simply reading the row again
and possibly sending another conditional mutation.  If this is not sufficient,
then a higher level of abstraction can be built by storing transactional
information within a row.

See the [reservations example][reservations] for example code that uses the [ConditionalWriter].

### Durability

By default, Accumulo writes out any updates to the Write-Ahead Log (WAL). Every change
goes into a file in HDFS and is sync'd to disk for maximum durability. In
the event of a failure, writes held in memory are replayed from the WAL. Like
all files in HDFS, this file is also replicated. Sending updates to the
replicas, and waiting for a permanent sync to disk can significantly slow down write speeds.

Accumulo allows users to use less tolerant forms of durability when writing.
These levels are:

* `none` - no durability guarantees are made, the WAL is not used
* `log` - the WAL is used, but not flushed; loss of the server probably means recent writes are lost
* `flush` - updates are written to the WAL, and flushed out to replicas; loss of a single server is unlikely to result in data loss.
* `sync` - updates are written to the WAL, and synced to disk on all replicas before the write is acknowledge. Data will not be lost even if the entire cluster suddenly loses power.

Durability can be set in multiple ways:

1. The default durability of all tables can be set using [table.durability].
    ```
    root@uno> config -s table.durability=flush
    ```
2. The default durability of a table can be overriden by setting [table.durability] for that table.
    ```
    root@uno> config -t mytable -s table.durability=sync
    ```
3. When creating a [AccumuloClient], the default durability can be overridden using `withBatchWriterConfig()`
   or by setting [batch.writer.durability] in [accumulo-client.properties].
4. When a BatchWriter or ConditionalWriter is created, the durability settings above will be overridden
   by the `BatchWriterConfig` that is passed in.

    ```java
    BatchWriterConfig cfg = new BatchWriterConfig();
    // We don't care about data loss with these writes:
    // This is DANGEROUS:
    cfg.setDurability(Durability.NONE);

    BatchWriter bw = client.createBatchWriter(table, cfg);
    ```

## Reading Data

Accumulo is optimized to quickly retrieve the value associated with a given key, and
to efficiently return ranges of consecutive keys and their associated values.

### Scanner

To retrieve data, create a [Scanner] using [AccumuloClient]. A Scanner acts like an Iterator over
keys and values in the table.

If a [Scanner] is created without [Authorizations], it uses all [Authorizations] granted
to the user that created the [AccumuloClient]:

```java
Scanner s = client.createScanner("table");
```

A scanner can also be created to only use a subset of a user's [Authorizations].

```java
Scanner s = client.createScanner("table", new Authorizations("public"));
```

Scanners can be configured to start and stop at particular keys, and
to return a subset of the columns available.

```java
// return data with visibilities that match specified auths
Authorizations auths = new Authorizations("public");

try (Scanner scan = client.createScanner("table", auths)) {
  scan.setRange(new Range("harry","john"));
  scan.fetchColumnFamily("attributes");

  for (Entry<Key,Value> entry : scan) {
    Text row = entry.getKey().getRow();
    Value value = entry.getValue();
  }
}
```

### Isolated Scanner

Accumulo supports the ability to present an isolated view of rows when
scanning. There are three possible ways that a row could change in Accumulo :

* a mutation applied to a table
* iterators executed as part of a minor or major compaction
* bulk import of new files

Isolation guarantees that either all or none of the changes made by these
operations on a row are seen. Use the [IsolatedScanner] to obtain an isolated
view of an Accumulo table. When using the regular scanner it is possible to see
a non isolated view of a row. For example if a mutation modifies three
columns, it is possible that you will only see two of those modifications.
With the isolated scanner either all three of the changes are seen or none.

The [IsolatedScanner] buffers rows on the client side so a large row will not
crash a tablet server. By default rows are buffered in memory, but the user
can easily supply their own buffer if they wish to buffer to disk when rows are
large.

See the [isolation example][isolation] for example code that uses the [IsolatedScanner].

### BatchScanner

For some types of access, it is more efficient to retrieve several ranges
simultaneously. This arises when accessing a set of rows that are not consecutive
whose IDs have been retrieved from a secondary index, for example.

The [BatchScanner] is configured similarly to the [Scanner]; it can be configured to
retrieve a subset of the columns available, but rather than passing a single [Range],
BatchScanners accept a set of Ranges. It is important to note that the keys returned
by a [BatchScanner] are not in sorted order since the keys streamed are from multiple
TabletServers in parallel.

```java
ArrayList<Range> ranges = new ArrayList<Range>();
// populate list of ranges ...

try (BatchScanner bscan = client.createBatchScanner("table", auths, 10)) {
  bscan.setRanges(ranges);
  bscan.fetchColumnFamily("attributes");

  for (Entry<Key,Value> entry : bscan) {
    System.out.println(entry.getValue());
  }
}
```

For more example code, see the [batch writing and scanning example][batch].

At this time, there is no client side isolation support for the [BatchScanner].
You may consider using the [WholeRowIterator] with the BatchScanner to achieve
isolation. The drawback of this approach is that entire rows are read into
memory on the server side. If a row is too big, it may crash a tablet server.

## Running Client Code

There are multiple ways to run Java code that use Accumulo. Below is a list
of the different ways to execute client code.

* build and execute an uber jar
* add `accumulo classpath` to your Java classpath
* use the `accumulo` command

### Build and execute an uber jar

If you have included `accumulo-core` as dependency in your pom, you can build an uber jar
using the Maven assembly or shade plugin and use it to run Accumulo client code. When building
an uber jar, you should set the versions of any Hadoop dependencies in your pom to match the
version running on your cluster.

### Add 'accumulo classpath' to your Java classpath

To run Accumulo client code using the `java` command, use the `accumulo classpath` command
to include all of Accumulo's dependencies on your classpath:

    java -classpath /path/to/my.jar:/path/to/dep.jar:$(accumulo classpath) com.my.Main arg1 arg2

### Use the accumulo command

Another option for running your code is to use the Accumulo script which can execute a
main class (if it exists on its classpath):

    accumulo com.foo.Client arg1 arg2

While the Accumulo script will add all of Accumulo's dependencies to the classpath, you
will need to add any jars that your create or depend on beyond what Accumulo already
depends on. This can be accomplished by either adding the jars to the `lib/ext` directory
of your Accumulo installation or by adding jars to the CLASSPATH variable before calling
the accumulo command.

    export CLASSPATH=/path/to/my.jar:/path/to/dep.jar; accumulo com.foo.Client arg1 arg2

## Additional Documentation

This page covers Accumulo client basics.  Below are links to additional documentation that may be useful when creating Accumulo clients:

* [Iterators] - Server-side programming mechanism that can modify key/value pairs at various points in data management process
* [Proxy] - Documentation for interacting with Accumulo using non-Java languages through a proxy server
* [MapReduce] - Documentation for reading and writing to Accumulo using MapReduce.

[AccumuloClient]: {% jurl org.apache.accumulo.core.client.AccumuloClient %}
[client-props]: {% durl configuration/client-properties %}
[auth.type]: {% purl -c auth.type %}
[auth.principal]: {% purl -c auth.principal %}
[auth.token]: {% purl -c auth.token %}
[instance.name]: {% purl -c instance.name %}
[instance.zookeepers]: {% purl -c instance.zookeepers %}
[batch.writer.durability]: {% purl -c batch.writer.durability %}
[PasswordToken]: {% jurl org.apache.accumulo.core.client.security.tokens.PasswordToken %}
[AuthenticationToken]: {% jurl org.apache.accumulo.core.client.security.tokens.AuthenticationToken %}
[CredentialProviderToken]: {% jurl org.apache.accumulo.core.client.security.tokens.CredentialProviderToken %}
[KerberosToken]: {% jurl org.apache.accumulo.core.client.security.tokens.KerberosToken %}
[Mutation]: {% jurl org.apache.accumulo.core.data.Mutation %}
[BatchWriter]: {% jurl org.apache.accumulo.core.client.BatchWriter %}
[ConditionalWriter]: {% jurl org.apache.accumulo.core.client.ConditionalWriter %}
[Scanner]: {% jurl org.apache.accumulo.core.client.Scanner %}
[IsolatedScanner]: {% jurl org.apache.accumulo.core.client.IsolatedScanner %}
[BatchScanner]: {% jurl org.apache.accumulo.core.client.BatchScanner %}
[Range]: {% jurl org.apache.accumulo.core.data.Range %}
[WholeRowIterator]: {% jurl org.apache.accumulo.core.iterators.user.WholeRowIterator %}
[Iterators]: {% durl development/iterators %}
[Proxy]: {% durl development/proxy %}
[MapReduce]: {% durl development/mapreduce %}
[batch]: https://github.com/apache/accumulo-examples/blob/master/docs/batch.md
[reservations]: https://github.com/apache/accumulo-examples/blob/master/docs/reservations.md
[isolation]: https://github.com/apache/accumulo-examples/blob/master/docs/isolation.md
[accumulo-client.properties]: {% durl configuration/files#accumulo-clientproperties %}
[table.durability]: {% purl table.durability %}
[Authorizations]: {% jurl org.apache.accumulo.core.security.Authorizations %}
