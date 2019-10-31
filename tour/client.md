---
title: Connecting to Accumulo
---

Connecting to a live instance of Accumulo is done through the [AccumuloClient] object.  This object contains a live connection
to Accumulo and will remain open until closed.  All client operations can be accessed from this one object.

The [Accumulo] entry point is used to create a client by calling ```Accumulo.newClient()```.  The client can
be created from properties by using one of the ```from()``` methods or using the ```to()``` and ```as()``` methods
to specify the connection information directly.

For the tour, the client is passed to each exercise method and then closed before stopping the cluster.
The properties used to create the client can be seen in ```accumulo-client.properties``` under ```target/mac######/conf```
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