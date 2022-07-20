---
title: Using Iterators
---

Suppose at the end of each day we record the number of villains a hero has caught that day. Iterators
can assist with this. Iterators are server-side programming mechanisms that allow filtering and
aggregation operations on data during scans and during compactions.

Let's begin by adding some data for our hero's recording recent crime-stopping statistics.

```commandlne
jshell> client.tableOperations().create("GothamCrimeStats");

jshell> Mutation mutation1 = new Mutation("id0001");
mutation1 ==> org.apache.accumulo.core.data.Mutation@1
jshell> mutation1.put("hero", "alias", "Batman");

// last three days of Batman's statistics
jshell> mutation1.put("hero", "villainsCaptured", "2");
jshell> mutation1.put("hero", "villainsCaptured", "1");
jshell> mutation1.put("hero", "villainsCaptured", "5");

jshell> Mutation mutation2 = new Mutation("id0002");
mutation2 ==> org.apache.accumulo.core.data.Mutation@1
jshell> mutation2.put("hero", "alias", "Robin");

// last three days of Robin's statistics
jshell> mutation2.put("hero", "villainsCaptured", "1");
jshell> mutation2.put("hero", "villainsCaptured", "0");
jshell> mutation2.put("hero", "villainsCaptured", "2");

jshell> try (BatchWriter writer = client.createBatchWriter("GothamCrimeStats")) {
   ...>   writer.addMutation(mutation1);
   ...>   writer.addMutation(mutation2);
   ...> }
```

Let's scan to see the data. 

```commandline
jshell> try (ScannerBase scan = client.createScanner("GothamCrimeStats", Authorizations.EMPTY)) {
   ...>   System.out.println("Gotham Police Department Crime Statistics:");
   ...>   for(Map.Entry<Key, Value> entry : scan) {
   ...>     System.out.printf("Key : %-52s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>   }
   ...> }
```   

You may notice a problem. We only see the latest entry. That is due to the
`versioningIterator` which is applied to all tables by default. It filters out all but the latest entry
when scanning a table. 

In order to see a record of past days we can remove the `versioningiterator` (you could also choose
a set number of past entries to display). The iterator is named `vers`.

To simplify, we will import some additional packages to save some typing.

```commandline
jshell> import org.apache.accumulo.core.iterators.IteratorUtil.IteratorScope;
jshell> client.tableOperations().removeIterator("GothamCrimeStats", "vers", EnumSet.allOf(IteratorScope.class));
```

Now let's scan again.

```commandline
jshell> try (ScannerBase scan = client.createScanner("GothamCrimeStats", Authorizations.EMPTY)) {
   ...>   System.out.println("Gotham Police Department Crime Statistics:");
   ...>   for(Map.Entry<Key, Value> entry : scan) {
   ...>     System.out.printf("Key : %-52s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>   }
   ...> }   
Gotham Police Department Crime Statistics:
Key : id0001 hero:alias [] 1654697915769 false              Value : Batman
Key : id0001 hero:villainsCaptured [] 1654697915769 false   Value : 5
Key : id0001 hero:villainsCaptured [] 1654697915769 false   Value : 1
Key : id0001 hero:villainsCaptured [] 1654697915769 false   Value : 2
Key : id0002 hero:alias [] 1654697915769 false              Value : Robin
Key : id0002 hero:villainsCaptured [] 1654697915769 false   Value : 2
Key : id0002 hero:villainsCaptured [] 1654697915769 false   Value : 0
Key : id0002 hero:villainsCaptured [] 1654697915769 false   Value : 1
```
 
You will now see ALL entries added to the table.

Instead of seeing a daily history, let's instead keep a running total of captured villains. 
A `summingcombiner` can be used to accomplish this.

```commandline
jshell> import org.apache.accumulo.core.iterators.user.SummingCombiner;
jshell> import org.apache.accumulo.core.iterators.LongCombiner
```

Create an IteratorSetting object. Set the encoding type and indicate the columns to be summed.
Also, it is a good idea to check for any iterator conflicts prior to attaching the iterator to the 
table.

```commandline
jshell> IteratorSetting scSetting = new IteratorSetting(30, "sum", SummingCombiner.class);
jshell> LongCombiner.setEncodingType(scSetting, LongCombiner.Type.STRING);
jshell> scSetting.addOption("columns", "hero:villainsCaptured");
jshell> client.tableOperations().checkIteratorConflicts("GothamCrimeStats", scSetting, EnumSet.allOf(IteratorScope.class));
jshell> client.tableOperations().attachIterator("GothamCrimeStats", scSetting);
```

Let's scan again and see what results we get.

```commandline
jshell> try ( org.apache.accumulo.core.client.Scanner scan = client.createScanner("GothamCrimeStats", Authorizations.EMPTY)) {
   ...>   for(Map.Entry<Key, Value> entry : scan) {
   ...>     System.out.printf("Key : %-52s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>   }
   ...> }
Key : id0001 hero:alias [] 1654699186182 false              Value : Batman
Key : id0001 hero:villainsCaptured [] 1654699186182 false   Value : 8
Key : id0002 hero:alias [] 1654699186182 false              Value : Robin
Key : id0002 hero:villainsCaptured [] 1654699186182 false   Value : 3
```

Adding additional statistics will result in a continual update of the relevant statistic.

```commandline
jshell> mutation1 = new Mutation("id0001");
jshell> mutation1.put("hero", "villainsCaptured", "4");
jshell> mutation2 = new Mutation("id0002");
jshell> mutation2.put("hero", "villainsCaptured", "2");

jshell> try (BatchWriter writer = client.createBatchWriter("GothamCrimeStats")) {
   ...>   writer.addMutation(mutation1);
   ...>   writer.addMutation(mutation2);
   ...> }

jshell> try ( org.apache.accumulo.core.client.Scanner scan = client.createScanner("GothamCrimeStats", Authorizations.EMPTY)) {
   ...>   for(Map.Entry<Key, Value> entry : scan) {
   ...>     System.out.printf("Key : %-52s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>   }
   ...> }
Key : id0001 hero:alias [] 1654779673027 false              Value : Batman
Key : id0001 hero:villainsCaptured [] 1654780041402 false   Value : 12
Key : id0002 hero:alias [] 1654779673027 false              Value : Robin
Key : id0002 hero:villainsCaptured [] 1654780041402 false   Value : 5
```
