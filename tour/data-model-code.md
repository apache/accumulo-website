---
title: Data Model Code
---

Below is the solution for the exercise.

```java
static void exercise(AccumuloClient client) throws Exception {
    // create a table called "GothamPD".
    client.tableOperations().create("GothamPD");

    // Create a row for Batman
    Mutation mutation1 = new Mutation("id0001");
    mutation1.put("hero","alias", "Batman");
    mutation1.put("hero","name", "Bruce Wayne");
    mutation1.put("hero","wearsCape?", "true");

    // Create a row for Robin
    Mutation mutation2 = new Mutation("id0002");
    mutation2.put("hero","alias", "Robin");
    mutation2.put("hero","name", "Dick Grayson");
    mutation2.put("hero","wearsCape?", "true");

    // Create a row for Joker
    Mutation mutation3 = new Mutation("id0003");
    mutation3.put("villain","alias", "Joker");
    mutation3.put("villain","name", "Unknown");
    mutation3.put("villain","wearsCape?", "false");

    // Create a BatchWriter to the GothamPD table and add your mutations to it.
    // Once the BatchWriter is closed by the try w/ resources, data will be available to scans.
    try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
        writer.addMutation(mutation1);
        writer.addMutation(mutation2);
        writer.addMutation(mutation3);
    }

    // Read and print all rows of the "GothamPD" table. Try w/ resources will close for us.
    try (Scanner scan = client.createScanner("GothamPD", Authorizations.EMPTY)) {
        System.out.println("Gotham Police Department Persons of Interest:");
        // A Scanner is an extension of java.lang.Iterable so behaves just like one.
        for (Map.Entry<Key, Value> entry : scan) {
            System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
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
