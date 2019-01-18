---
title: Data Model Code
---

Below is the solution for the exercise.

```java
static void exercise(MiniAccumuloCluster mac) {

  // Create an AccumuloClient to Mini Accumulo
  try (AccumuloClient client = Accumulo.newClient().from(mac.getClientProperties()).build()) {

    // Create the GothamPD table
    client.tableOperations().create("GothamPD");

    // Create a BatchWriter to the GothamPD table
    // Data is available for scans after BatchWriter is closed
    try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
      // Create a row for Batman
      Mutation mut1 = new Mutation("id0001");
      mut1.at().family("hero").qualifier("alias").put("Batman");
      mut1.at().family("hero").qualifier("name").put("Bruce Wayne");
      mut1.at().family("hero").qualifier("wearsCape?").put("true");
      writer.addMutation(mut1);

      // Create a row for Robin
      Mutation mut2 = new Mutation("id0002");
      mut2.at().family("hero").qualifier("alias").put("Robin");
      mut2.at().family("hero").qualifier("name").put("Dick Grayson");
      mut2.at().family("hero").qualifier("wearsCape?").put("true");
      writer.addMutation(mut2);

      // Create a row for Joker
      Mutation mut3 = new Mutation("id0002");
      mut3.at().family("villain").qualifier("alias").put("Joker");
      mut3.at().family("villain").qualifier("name").put("Unknown");
      mut3.at().family("villain").qualifier("wearsCape?").put("false");
      writer.addMutation(mut3);
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

The code above will print (timestamp will differ):
```commandline
Gotham Police Department Persons of Interest:
Key : id0001 hero:alias [] 1511306370025 false            Value : Batman
Key : id0001 hero:name [] 1511306370025 false             Value : Bruce Wayne
Key : id0001 hero:wearsCape? [] 1511306370025 false       Value : true
Key : id0002 hero:alias [] 1511306370025 false            Value : Robin
Key : id0002 hero:name [] 1511306370025 false             Value : Dick Grayson
Key : id0002 hero:wearsCape? [] 1511306370025 false       Value : true
Key : id0003 villain:alias [] 1511306370025 false         Value : Joker
Key : id0003 villain:name [] 1511306370025 false          Value : Unknown
Key : id0003 villain:wearsCape? [] 1511306370025 false    Value : false
``` 
