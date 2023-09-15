---
title: Batch Scanner Code
---

Below is a solution to the exercise.

Create a table called "GothamBatch".

```
jshell> client.tableOperations().create("GothamBatch");
```

Generate 10,000 rows of villain data

```
jshell> try (BatchWriter writer = client.createBatchWriter("GothamBatch")) {
   ...>   for (int i = 0; i < 10_000; i++) {
   ...>     Mutation m = new Mutation(String.format("id%04d", i));
   ...>     m.put("villain", "alias", "henchman" + i);
   ...>     m.put("villain", "yearsOfService", "" + (new Random().nextInt(50)));
   ...>     m.put("villain", "wearsCape?", "false");
   ...>    writer.addMutation(m);
   ...>   }
   ...> }
```

Create a BatchScanner with 5 query threads
```
jshell> try (BatchScanner batchScanner = client.createBatchScanner("GothamBatch", Authorizations.EMPTY, 5)) {
   ...>
   ...>   // Create a collection of 2 sample ranges and set it to the batchScanner
   ...>   List<Range> ranges = new ArrayList<Range>();
   ...>
   ...>   // Create a collection of 2 sample ranges and set it to the batchScanner
   ...>   ranges.add(new Range("id1000", "id1999"));
   ...>   ranges.add(new Range("id9000", "id9999"));
   ...>   batchScanner.setRanges(ranges);
   ...>
   ...>   // Fetch just the columns we want
   ...>   batchScanner.fetchColumn(new Text("villain"), new Text("yearsOfService"));
   ...>
   ...>   // Calculate average years of service
   --->   long villianCount = batchScanner.stream().count();
   --->   Double average = batchScanner.stream().map(Map.Entry::getValue).map(Value::toString).mapToLong(Long::valueOf).average().getAsDouble();
   --->   System.out.println("The average years of service of " + villianCount + " villians is " + average);
   ...> }
```

Running the solution above should print output similar to below:

```
The average years of service of 2000 villains is 24.8125
```
