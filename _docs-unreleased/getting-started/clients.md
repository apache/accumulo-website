---
title: Accumulo Clients
category: getting-started
order: 2
---

## Running Client Code

There are multiple ways to run Java code that uses Accumulo. Below is a list
of the different ways to execute client code.

* using the `java` command
* using the `accumulo` command
* using the `accumulo-util hadoop-jar` command

### Using the java command

To run Accumulo client code using the `java` command, use the `accumulo classpath` command 
to include all of Accumulo's dependencies on your classpath:

    java -classpath /path/to/my.jar:/path/to/dep.jar:$(accumulo classpath) com.my.Main arg1 arg2

If you would like to review which jars are included, the `accumulo classpath` command can
output a more human readable format using the `-d` option which enables debugging:

    accumulo classpath -d

### Using the accumulo command

Another option for running your code is to use the Accumulo script which can execute a
main class (if it exists on its classpath):

    accumulo com.foo.Client arg1 arg2

While the Accumulo script will add all of Accumulo's dependencies to the classpath, you
will need to add any jars that your create or depend on beyond what Accumulo already
depends on. This can be accomplished by either adding the jars to the `lib/ext` directory
of your Accumulo installation or by adding jars to the CLASSPATH variable before calling
the accumulo command.

    export CLASSPATH=/path/to/my.jar:/path/to/dep.jar; accumulo com.foo.Client arg1 arg2

### Using the 'accumulo-util hadoop-jar' command

If you are writing map reduce job that accesses Accumulo, then you can use
`accumulo-util hadoop-jar` to run those jobs. See the map reduce example.

## Connecting

All clients must first identify the Accumulo instance to which they will be
communicating. Code to do this is as follows:

```java
String instanceName = "myinstance";
String zooServers = "zooserver-one,zooserver-two"
Instance inst = new ZooKeeperInstance(instanceName, zooServers);

Connector conn = inst.getConnector("user", new PasswordToken("passwd"));
```

The [PasswordToken] is the most common implementation of an [AuthenticationToken].
This general interface allow authentication as an Accumulo user to come from
a variety of sources or means. The [CredentialProviderToken] leverages the Hadoop
CredentialProviders (new in Hadoop 2.6).

For example, the [CredentialProviderToken] can be used in conjunction with a Java
KeyStore to alleviate passwords stored in cleartext. When stored in HDFS, a single
KeyStore can be used across an entire instance. Be aware that KeyStores stored on
the local filesystem must be made available to all nodes in the Accumulo cluster.

```java
KerberosToken token = new KerberosToken();
Connector conn = inst.getConnector(token.getPrincipal(), token);
```

The [KerberosToken] can be provided to use the authentication provided by Kerberos.
Using Kerberos requires external setup and additional configuration, but provides
a single point of authentication through HDFS, YARN and ZooKeeper and allowing
for password-less authentication with Accumulo.

## Writing Data

Data are written to Accumulo by creating [Mutation] objects that represent all the
changes to the columns of a single row. The changes are made atomically in the
TabletServer. Clients then add Mutations to a [BatchWriter] which submits them to
the appropriate TabletServers.

Mutations can be created thus:

```java
Text rowID = new Text("row1");
Text colFam = new Text("myColFam");
Text colQual = new Text("myColQual");
ColumnVisibility colVis = new ColumnVisibility("public");
long timestamp = System.currentTimeMillis();

Value value = new Value("myValue".getBytes());

Mutation mutation = new Mutation(rowID);
mutation.put(colFam, colQual, colVis, timestamp, value);
```

### BatchWriter

The [BatchWriter] is highly optimized to send Mutations to multiple TabletServers
and automatically batches Mutations destined for the same TabletServer to
amortize network overhead. Care must be taken to avoid changing the contents of
any Object passed to the BatchWriter since it keeps objects in memory while
batching.

Mutations are added to a BatchWriter thus:

```java
// BatchWriterConfig has reasonable defaults
BatchWriterConfig config = new BatchWriterConfig();
config.setMaxMemory(10000000L); // bytes available to batchwriter for buffering mutations

BatchWriter writer = conn.createBatchWriter("table", config)

writer.addMutation(mutation);

writer.close();
```

For more example code, see the [batch writing and scanning example](https://github.com/apache/accumulo-examples/blob/master/docs/batch.md).

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
the ConditionalWriter reports a status of UNKNOWN for the ConditionalMutation.
In many cases this situation can be dealt with by simply reading the row again
and possibly sending another conditional mutation.  If this is not sufficient,
then a higher level of abstraction can be built by storing transactional
information within a row.

See the [reservations example](https://github.com/apache/accumulo-examples/blob/master/docs/reservations.md)
for example code that uses the conditional writer.

### Durability

By default, Accumulo writes out any updates to the Write-Ahead Log (WAL). Every change
goes into a file in HDFS and is sync'd to disk for maximum durability. In
the event of a failure, writes held in memory are replayed from the WAL. Like
all files in HDFS, this file is also replicated. Sending updates to the
replicas, and waiting for a permanent sync to disk can significantly write speeds.

Accumulo allows users to use less tolerant forms of durability when writing.
These levels are:

* none: no durability guarantees are made, the WAL is not used
* log: the WAL is used, but not flushed; loss of the server probably means recent writes are lost
* flush: updates are written to the WAL, and flushed out to replicas; loss of a single server is unlikely to result in data loss.
* sync: updates are written to the WAL, and synced to disk on all replicas before the write is acknowledge. Data will not be lost even if the entire cluster suddenly loses power.

The user can set the default durability of a table in the shell.  When
writing, the user can configure the BatchWriter or ConditionalWriter to use
a different level of durability for the session. This will override the
default durability setting.

```java
BatchWriterConfig cfg = new BatchWriterConfig();
// We don't care about data loss with these writes:
// This is DANGEROUS:
cfg.setDurability(Durability.NONE);

Connection conn = ... ;
BatchWriter bw = conn.createBatchWriter(table, cfg);
```

## Reading Data

Accumulo is optimized to quickly retrieve the value associated with a given key, and
to efficiently return ranges of consecutive keys and their associated values.

### Scanner

To retrieve data, Clients use a [Scanner], which acts like an Iterator over
keys and values. Scanners can be configured to start and stop at particular keys, and
to return a subset of the columns available.

```java
// specify which visibilities we are allowed to see
Authorizations auths = new Authorizations("public");

Scanner scan =
    conn.createScanner("table", auths);

scan.setRange(new Range("harry","john"));
scan.fetchColumnFamily(new Text("attributes"));

for(Entry<Key,Value> entry : scan) {
    Text row = entry.getKey().getRow();
    Value value = entry.getValue();
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

See the [isolation example](https://github.com/apache/accumulo-examples/blob/master/docs/isolation.md)
for example code that uses the IsolatedScanner.

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

BatchScanner bscan =
    conn.createBatchScanner("table", auths, 10);
bscan.setRanges(ranges);
bscan.fetchColumnFamily("attributes");

for(Entry<Key,Value> entry : bscan) {
    System.out.println(entry.getValue());
}
```

For more example code, see the [batch writing and scanning example](https://github.com/apache/accumulo-examples/blob/master/docs/batch.md).

At this time, there is no client side isolation support for the [BatchScanner].
You may consider using the [WholeRowIterator] with the BatchScanner to achieve
isolation. The drawback of this approach is that entire rows are read into
memory on the server side. If a row is too big, it may crash a tablet server.

## Additional Documentation

This page covers Accumulo client basics.  Below are links to additional documentation that may be useful when creating Accumulo clients:

* [Iterators] - Server-side programming mechanism that can modify key/value pairs at various points in data management process
* [Proxy] - Documentation for interacting with Accumulo using non-Java languages through a proxy server
* [MapReduce] - Documentation for reading and writing to Accumulo using MapReduce.

[PasswordToken]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/security/tokens/PasswordToken.html
[AuthenticationToken]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/security/tokens/AuthenticationToken.html
[CredentialProviderToken]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/security/tokens/CredentialProviderToken.html
[KerberosToken]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/security/tokens/KerberosToken.html
[Mutation]: {{ page.javadoc_core }}/org/apache/accumulo/core/data/Mutation.html
[BatchWriter]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/BatchWriter.html
[ConditionalWriter]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/ConditionalWriter.html
[Scanner]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/Scanner.html
[IsolatedScanner]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/IsolatedScanner.html
[BatchScanner]: {{ page.javadoc_core}}/org/apache/accumulo/core/client/BatchScanner.html
[Range]: {{ page.javadoc_core }}/org/apache/accumulo/core/data/Range.html
[WholeRowIterator]: {{ page.javadoc_core }}/org/apache/accumulo/core/iterators/user/WholeRowIterator.html
[Iterators]: {{ page.docs_baseurl }}/development/iterators
[Proxy]: {{ page.docs_baseurl }}/development/proxy
[MapReduce]: {{ page.docs_baseurl }}/development/mapreduce
