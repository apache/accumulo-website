---
title: Data Model Code
---

```java
        // Connect to Mini Accumulo as the root user and create a table called "GothamPD".
        Connector conn = mac.getConnector("root", "tourguide");
        conn.tableOperations().create("GothamPD");

        // Create 3 Mutation objects to hold each person of interest.
        Mutation mutation1 = new Mutation("id0001");
        Mutation mutation2 = new Mutation("id0002");
        Mutation mutation3 = new Mutation("id0003");

        // Create key/value pairs for each Mutation, putting them in the appropriate family.
        mutation1.put("hero","alias", "Batman");
        mutation1.put("hero","name", "Bruce Wayne");
        mutation1.put("hero","wearsCape?", "true");
        mutation2.put("hero","alias", "Robin");
        mutation2.put("hero","name", "Dick Grayson");
        mutation2.put("hero","wearsCape?", "true");
        mutation3.put("villain","alias", "Joker");
        mutation3.put("villain","name", "Unknown");
        mutation3.put("villain","wearsCape?", "false");

        // Create a BatchWriter to the GothamPD table and add your mutations to it.  Try w/ resources will close for us.
        try(BatchWriter writer = conn.createBatchWriter("GothamPD", new BatchWriterConfig())) {
            writer.addMutation(mutation1);
            writer.addMutation(mutation2);
            writer.addMutation(mutation3);
        }

        // Read and print all rows of the "GothamPD" table. Try w/ resources will close for us.
        try(Scanner scan = conn.createScanner("GothamPD", Authorizations.EMPTY)) {
            System.out.println("Gotham Police Department Persons of Interest:");
            // A Scanner is an extension of java.lang.Iterable so behaves just like one.
            for (Map.Entry<Key, Value> entry : scan) {
                System.out.println("Key:" + entry.getKey());
                System.out.println("Value:" + entry.getValue());
            }
        }
```

The code above will print (timestamp will differ):
```commandline
Gotham Police Department Persons of Interest:
Key:id0001 hero:alias [] 1510084285325 false
Value:Batman
Key:id0001 hero:name [] 1510084285325 false
Value:Bruce Wayne
Key:id0001 hero:wearsCape? [] 1510084285325 false
Value:true
Key:id0002 hero:alias [] 1510084285325 false
Value:Robin
Key:id0002 hero:name [] 1510084285325 false
Value:Dick Grayson
Key:id0002 hero:wearsCape? [] 1510084285325 false
Value:true
Key:id0003 villain:alias [] 1510084285325 false
Value:Joker
Key:id0003 villain:name [] 1510084285325 false
Value:Unknown
Key:id0003 villain:wearsCape? [] 1510084285325 false
Value:false
``` 