---
title: Writing and Reading
---
Accumulo is a big data key/value store.  Writing data to Accumulo is flexible and fast.  Like any database, Accumulo stores
data in tables and rows.  Each row in an Accumulo table can hold many key/value pairs.  

1. Start by connecting to Mini Accumulo and create a table called "superheroes".  For now, connect as the root user.
```java
Connector conn = mac.getConnector("root", "tourguide");
conn.tableOperations().create("superheroes");
```

2. Create a Mutation object for row1
```java
Mutation mutation = new Mutation("row1");
```
A Mutation is an object that holds all changes to a row in a table.  Each row has a unique row ID.
 
3. Create key/value pairs for Batman.
```java
mutation.put("name", "", "Batman");
mutation.put("real-name", "", "Bruce Wayne");
mutation.put("wearsCape?", "", "true");
mutation.put("flies?", "", "false");
```
Every Mutation in Accumulo is atomic. This means that all the changes to a single row will happen at once. The Mutation
object conveniently allows us to put all the changes for the row in one spot. 

4. Create a BatchWriter to the superhero table and add your mutation to it.
```java
BatchWriter writer = conn.createBatchWriter("superheroes", new BatchWriterConfig());
writer.addMutation(mutation);
writer.close();
```
Accumulo is very efficient, so it prefers data to arrive in batches.  The BatchWriter will take care of this for us.
Once we are finished, closing the BatchWriter will tell Accumulo everything is good to go.

5. Print all rows of the "superheroes" table
```java
Scanner scan = conn.createScanner("superheroes", Authorizations.EMPTY);
System.out.println("superheroes table contents:");
for(java.util.Map.Entry entry : scan) {
    System.out.println("Key:" + entry.getKey());
    System.out.println("Value:" + entry.getValue());
}
```
A Scanner is the object that Accumulo clients use to read data efficiently. A Scanner is an extension of 
java.util.Iterator so behaves just like one. More on Scanners later.  


6. Build and run your code
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