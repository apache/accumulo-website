---
title: Proxy
category: development
order: 3
---

The proxy API allows the interaction with Accumulo with languages other than Java.
A proxy server is provided in the codebase and a client can further be generated.
The proxy API can also be used instead of the traditional ZooKeeperInstance class to
provide a single TCP port in which clients can be securely routed through a firewall,
without requiring access to all tablet servers in the cluster.

## Prerequisites

The proxy server can live on any node in which the basic client API would work. That
means it must be able to communicate with the Master, ZooKeepers, NameNode, and the
DataNodes. A proxy client only needs the ability to communicate with the proxy server.

## Configuration

The configuration options for the proxy server live inside of a properties file. At
the very least, you need to supply the following properties:

    protocolFactory=org.apache.thrift.protocol.TCompactProtocol$Factory
    tokenClass=org.apache.accumulo.core.client.security.tokens.PasswordToken
    port=42424
    instance=test
    zookeepers=localhost:2181

You can find a sample configuration file in your distribution at `proxy/proxy.properties`.

This sample configuration file further demonstrates an ability to back the proxy server
by MockAccumulo or the MiniAccumuloCluster.

## Running the Proxy Server

After the properties file holding the configuration is created, the proxy server
can be started using the following command in the Accumulo distribution (assuming
your properties file is named `config.properties`):

    accumulo proxy -p config.properties

## Creating a Proxy Client

Aside from installing the Thrift compiler, you will also need the language-specific library
for Thrift installed to generate client code in that language. Typically, your operating
system's package manager will be able to automatically install these for you in an expected
location such as `/usr/lib/python/site-packages/thrift`.

You can find the thrift file for generating the client at `proxy/proxy.thrift`.

After a client is generated, the port specified in the configuration properties above will be
used to connect to the server.

## Using a Proxy Client

The following examples have been written in Java and the method signatures may be
slightly different depending on the language specified when generating client with
the Thrift compiler. After initiating a connection to the Proxy (see Apache Thrift's
documentation for examples of connecting to a Thrift service), the methods on the
proxy client will be available. The first thing to do is log in:

```java
Map password = new HashMap<String,String>();
password.put("password", "secret");
ByteBuffer token = client.login("root", password);
```

Once logged in, the token returned will be used for most subsequent calls to the client.
Let's create a table, add some data, scan the table, and delete it.

First, create a table.

```java
client.createTable(token, "myTable", true, TimeType.MILLIS);
```

Next, add some data:

```java
// first, create a writer on the server
String writer = client.createWriter(token, "myTable", new WriterOptions());

//rowid
ByteBuffer rowid = ByteBuffer.wrap("UUID".getBytes());

//mutation like class
ColumnUpdate cu = new ColumnUpdate();
cu.setColFamily("MyFamily".getBytes());
cu.setColQualifier("MyQualifier".getBytes());
cu.setColVisibility("VisLabel".getBytes());
cu.setValue("Some Value.".getBytes());

List<ColumnUpdate> updates = new ArrayList<ColumnUpdate>();
updates.add(cu);

// build column updates
Map<ByteBuffer, List<ColumnUpdate>> cellsToUpdate = new HashMap<ByteBuffer, List<ColumnUpdate>>();
cellsToUpdate.put(rowid, updates);

// send updates to the server
client.updateAndFlush(writer, "myTable", cellsToUpdate);

client.closeWriter(writer);
```

Scan for the data and batch the return of the results on the server:

```java
String scanner = client.createScanner(token, "myTable", new ScanOptions());
ScanResult results = client.nextK(scanner, 100);

for(KeyValue keyValue : results.getResultsIterator()) {
  // do something with results
}

client.closeScanner(scanner);
```

