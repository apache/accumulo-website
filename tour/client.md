---
title: Connecting to Accumulo
---

Connecting to a live instance of Accumulo is done through the [AccumuloClient] object.  This object contains a live connection
to Accumulo and will remain open until closed.  All client operations can be accessed from this one object.

Typically, the [Accumulo] entry point is used to create a client by calling ```Accumulo.newClient()``` but for the tour
a client is created for us from MiniAccumulo.  It is passed to each exercise method and then closed before stopping the cluster.
Notice the client can be wrapped in a Java try-with-resources since it is AutoCloseable.

Start by using table operations to list the default tables and instance operations to get the instance ID.
```java
static void exercise(AccumuloClient client) throws Exception {
    for (String t : client.tableOperations().list())
        System.out.println("Table: " + t);

    System.out.println("Instance ID: " + client.instanceOperations().getInstanceID());
}
```

Different types of operations are accessed by their respective method on the client:
```java
client.tableOperations();
client.namespaceOperations();
client.securityOperations();
client.instanceOperations();
client.replicationOperations();
```

The client is also used directly to create Scanners and perform batch operations.  These will be explored later.

[AccumuloClient]: {% jurl org.apache.accumulo.core.client.AccumuloClient %}
[Accumulo]: {% jurl org.apache.accumulo.core.client.Accumulo %}