---
title: Writing and Reading
---
Accumulo is a big data key/value store.  Writing data to Accumulo is flexible and fast.  Like any database, Accumulo stores
data in tables and rows.  Each row in an Accumulo table can hold many key/value pairs.  

Copy and paste the code below into the _exercise_  method.
```java
        // 1. Start by connecting to Mini Accumulo as the root user and create a table called "superheroes".
        Connector conn = mac.getConnector("root", "tourguide");
        conn.tableOperations().create("superheroes");

        // 2. Create a Mutation object to write to a row
        Mutation mutation = new Mutation("hero023948092");
        // A Mutation is an object that holds all changes to a row in a table.  Each row has a unique row ID.

        // 3. Create key/value pairs for Batman.  Put them in the "HeroAttribute" family.
        mutation.put("HeroAttribute","name", "Batman");
        mutation.put("HeroAttribute","real-name", "Bruce Wayne");
        mutation.put("HeroAttribute","wearsCape?", "true");
        mutation.put("HeroAttribute","flies?","false");

        // 4. Create a BatchWriter to the superhero table and add your mutation to it.  Try w/ resources will close for us.
        try(BatchWriter writer = conn.createBatchWriter("superheroes", new BatchWriterConfig())) {
            writer.addMutation(mutation);
        } catch(TableNotFoundException | MutationsRejectedException e) {
            System.out.println("Error in the BatchWriter:");
            e.printStackTrace();
        }

        // 5. Read and print all rows of the "superheroes" table. Try w/ resources will close for us.
        try(Scanner scan = conn.createScanner("superheroes", Authorizations.EMPTY)) {
            System.out.println("superheroes table contents:");
            // A Scanner is an extension of java.lang.Iterable so behaves just like one.
            for (Map.Entry<Key, Value> entry : scan) {
                System.out.println("Key:" + entry.getKey());
                System.out.println("Value:" + entry.getValue());
            }
        } catch(TableNotFoundException e) {
            System.out.println("Error performing scan:");
            e.printStackTrace();
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