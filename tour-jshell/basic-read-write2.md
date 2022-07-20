---
title: Writing and Reading
---

Accumulo is a big key/value store.  Writing data to Accumulo is flexible and fast.  Like any 
database, Accumulo stores data in tables and rows.  Each row in an Accumulo table can hold many 
key/value pairs. 

Our next exercise shows how to write and read from a table.

Let's create a table called "GothamPD".

At the JShell prompt, enter the following:
```commandline
jshell> client.tableOperations().create("GothamPD");
```

Accumulo uses Mutation objects to hold all changes to a row in a table. Each row has a unique row
ID. 

```commandline
jshell> Mutation mutation1 = new Mutation("id0001");
mutation1 ==> org.apache.accumulo.core.data.Mutation@1
```

Create key/value pairs for Batman.  Put them in the "hero" family.
```commandline
jshell> mutation1.put("hero","alias", "Batman");
jshell> mutation1.put("hero","name", "Bruce Wayne");
jshell> mutation1.put("hero","wearsCape?", "true");
```

Create a BatchWriter to the GothamPD table and add your mutation to it. Try-with-resources will 
close for us.

```commandline
jshell> try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
  ...>    writer.addMutation(mutation1);
  ...>  }
```
Read and print all rows of the "GothamPD" table.

Note that within the JShell environment, references to Scanner are ambiguous since it matches both 
interface ```org.apache.accumulo.core.client.Scanner``` and class ```java.util.Scanner```. This can 
be resolved by either using the fully qualified name for the Scanner, or more easily, by using the 
base class, ```ScannerBase```, in place of ```Scanner``` (this should generally only be required when 
within the JShell environment).

```commandline
jshell> try (ScannerBase scan = client.createScanner("GothamPD", Authorizations.EMPTY)) {
   ...>   System.out.println("Gotham Police Department Persons of Interest:");
   ...>   for(Map.Entry<Key, Value> entry : scan) {
   ...>     System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>   }
   ...> }
Gotham Police Department Persons of Interest:
Key : id0001 hero:alias [] 1654274195071 false            Value : Batman
Key : id0001 hero:name [] 1654274195071 false             Value : Bruce Wayne
Key : id0001 hero:wearsCape? [] 1654274195071 false       Value : true
```

Be aware the timestamps will differ for you.

Good job! That is all it takes to write and read from Accumulo.

Notice a lot of other information was printed from the Keys we created. Accumulo is flexible 
because hidden within its [Key] is a rich data model that can be broken up into different parts. We 
will cover the [Data Model][dmodel] in the next lesson.

### But wait... I thought Accumulo was all about Security?

Spoiler Alert: It is!  Did you notice the `Authorizations.EMPTY` we passed in when creating a
[Scanner]?  The data we created in this first lesson was not secured with Authorizations so the 
Scanner didn't require any Authorizations to read it.  More to come later in the [Authorizations][auths] 
lesson!

[dmodel]: /tour-jshell/data-model2
[auths]: /tour-jshell/authorizations2
[Key]: {% jurl org.apache.accumulo.core.data.Key %}
[Scanner]: {% jurl org.apache.accumulo.core.client.Scanner %}
