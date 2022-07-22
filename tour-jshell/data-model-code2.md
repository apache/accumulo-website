---
title: Data Model Code
---

Below is the solution for the complete exercise.

```commandline
jshell> client.tableOperations().create("GothamPD");
```
Create a row for Batman
```commandline
jshell> Mutation mutation1 = new Mutation("id0001");
mutation1 ==> org.apache.accumulo.core.data.Mutation@1

jshell> mutation1.put("hero","alias", "Batman");
jshell> mutation1.put("hero","name", "Bruce Wayne");
jshell> mutation1.put("hero","wearsCape?", "true");
```

Create a row for Robin
```commandline
jshell> Mutation mutation2 = new Mutation("id0002");
mutation2 ==> org.apache.accumulo.core.data.Mutation@1

jshell> mutation2.put("hero","alias", "Robin");
jshell> mutation2.put("hero","name", "Dick Grayson");
jshell> mutation2.put("hero","wearsCape?", "true");
```    

Create a row for Joker
```commandline
jshell> Mutation mutation3 = new Mutation("id0003");
mutation3 ==> org.apache.accumulo.core.data.Mutation@1

jshell> mutation3.put("villain","alias", "Joker");
jshell> mutation3.put("villain","name", "Unknown");
jshell> mutation3.put("villain","wearsCape?", "false");
```

Create a BatchWriter to the GothamPD table and add your mutations to it.
Once the BatchWriter is closed by the try-with-resources, data will be available to scans.

```commandline
jshell> try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
   ...>   writer.addMutation(mutation1);
   ...>   writer.addMutation(mutation2);
   ...>   writer.addMutation(mutation3);
   ...> }
```

Read and print all rows of the "GothamPD" table. Try-with-resources will close for us.

Note: A Scanner is an extension of ```java.lang.Iterable``` so it will traverse through the table.

```commandline
jshell> try (ScannerBase scan = client.createScanner("GothamPD", Authorizations.EMPTY)) {
   ...>   System.out.println("Gotham Police Department Persons of Interest:");
   ...>     for (Map.Entry<Key, Value> entry : scan) {
   ...>     System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>   }
   ...> }
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
Timestamps will differ.


