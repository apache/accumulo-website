---
title: Writing and Reading
---
Accumulo is a big data key/value store.  Writing data to Accumulo is flexible and fast.  Like any database, Accumulo stores
data in tables and rows.  Each row in an Accumulo table can hold many key/value pairs.  

Here are the steps for writing to a table and then reading from it. Copy and paste the code below into the _exercise_  method.  Note each step is commented. 
```java
        // 1. Connect to Mini Accumulo as the root user and create a table called "GothamPD".
        Connector conn = mac.getConnector("root", "tourguide");
        conn.tableOperations().create("GothamPD");

        // 2. Create a Mutation object to hold all changes to a row in a table.  Each row has a unique row ID.
        Mutation mutation = new Mutation("id0001");

        // 3. Create key/value pairs for Batman.  Put them in the "hero" family.
        mutation.put("hero","alias", "Batman");
        mutation.put("hero","name", "Bruce Wayne");
        mutation.put("hero","wearsCape?", "true");

        // 4. Create a BatchWriter to the GothamPD table and add your mutation to it.  Try w/ resources will close for us.
        try(BatchWriter writer = conn.createBatchWriter("GothamPD", new BatchWriterConfig())) {
            writer.addMutation(mutation);
        }

        // 5. Read and print all rows of the "GothamPD" table. Try w/ resources will close for us.
        try(Scanner scan = conn.createScanner("GothamPD", Authorizations.EMPTY)) {
            System.out.println("Gotham Police Department Persons of Interest:");
            // A Scanner is an extension of java.lang.Iterable so behaves just like one.
            for (Map.Entry<Key, Value> entry : scan) {
                System.out.println("Key:" + entry.getKey());
                System.out.println("Value:" + entry.getValue());
            }
        }
```

Build and run your code
```commandline
mvn -q clean compile exec:java
``` 

Good job!  That is all it takes to write and read from Accumulo.  

Notice a lot of other information was printed from the Keys we created. Accumulo is flexible because hidden within its 
Key is a rich data model that can be broken up into different parts.  We will cover the [Data Model][dmodel] in the next lesson.

### But wait... I thought Accumulo was all about Security?  
Spoiler Alert: it is!  Did you notice the _Authorizations.EMPTY_ we passed to the Scanner on step 5?  The data
we created in this first lesson was not secured with Authorizations so the Scanner didn't require any Authorizations 
to read it.  More to come later in the [Authorizations][auths] lesson! 

[dmodel]: /tour/data-model
[auths]: /tour/authorizations