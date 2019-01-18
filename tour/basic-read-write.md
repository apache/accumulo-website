---
title: Writing and Reading
---
Accumulo is a big key/value store.  Writing data to Accumulo is flexible and fast.  Like any database, Accumulo stores
data in tables and rows.  Each row in an Accumulo table can hold many key/value pairs. Our next exercise shows how to
write and read from a table.

```java
static void exercise(MiniAccumuloCluster mac) {

  // Create an AccumuloClient to Mini Accumulo
  try (AccumuloClient client = Accumulo.newClient().from(mac.getClientProperties()).build()) {

    // Create the GothamPD table
    client.tableOperations().create("GothamPD");

    // Create a BatchWriter to the GothamPD table and add Batman
    try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
      // Create a Mutation that modifies the 'id0001' row
      Mutation mutation = new Mutation("id0001");
      // Create entries for Batman in the row
      mutation.at().family("hero").qualifier("alias").put("Batman");
      mutation.at().family("hero").qualifier("name").put("Bruce Wayne");
      mutation.at().family("hero").qualifier("wearsCape?").put("true");
      // Add the mutation to the BatchWriter
      writer.addMutation(mutation);
    }

    // Read and print all rows of the "GothamPD" table
    try (Scanner scan = client.createScanner("GothamPD", Authorizations.EMPTY)) {
      System.out.println("Gotham Police Department Persons of Interest:");
      // A Scanner is an extension of java.lang.Iterable so behaves just like one.
      for (Map.Entry<Key, Value> entry : scan) {
        System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
      }
    }
  }
}
```

Copy this code into your `exercise` method and run it using the command below.

```commandline
mvn -q clean compile exec:java
``` 

Good job! That is all it takes to write and read from Accumulo.

Notice a lot of other information was printed from the Keys we created. Accumulo is flexible because hidden within its 
[Key] is a rich data model that can be broken up into different parts.  We will cover the [Data Model][dmodel] in the next lesson.

### But wait... I thought Accumulo was all about Security?

Spoiler Alert: it is!  Did you notice the `Authorizations.EMPTY` we passed in when creating a [Scanner]?  The data
we created in this first lesson was not secured with Authorizations so the Scanner didn't require any Authorizations 
to read it.  More to come later in the [Authorizations][auths] lesson! 

[dmodel]: /tour/data-model
[auths]: /tour/authorizations
[Key]: {% jurl org.apache.accumulo.core.data.Key %}
[Scanner]: {% jurl org.apache.accumulo.core.client.Scanner %}
