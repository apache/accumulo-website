---
title: Batch Scanner
---

Running on a single thread, a `Scanner` will retrieve a single `Range` of data and return `Key`s in 
sorted order. A [BatchScanner] will retrieve multiple `Range`s of data using multiple threads.  A 
`BatchScanner` can be more efficient but does not guarantee `Key`s will be returned in sorted order.

For this exercise, we need to generate a bunch of data to test BatchScanner.  Execute the code below
to create our data set.

```commandline
jshell> try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
   ...>   for (int i = 0; i < 10_000; i++) {
   ...>     Mutation m = new Mutation(String.format("id%04d", i));
   ...>     m.put("villain", "alias", "henchman" + i);
   ...>     m.put("villain", "yearsOfService", "" + (new Random().nextInt(50)));
   ...>     m.put("villain", "wearsCape?", "false");
   ...>     writer.addMutation(m);
   ...>   }
   ...> }
```

We want to calculate the average years of service from a sample of 2000 villains. A BatchScanner would 
be good for this task because we don't need the returned keys to be sorted. Follow these steps to 
efficiently scan the table with 10,000 entries.

1. After the above code, create a BatchScanner with five query threads.  Similar to a Scanner, use 
the [createBatchScanner] method.

2. Create an ArrayList of two sample `Range`s (`id1000` to `id1999` and `id9000` to `id9999`) and set 
the ranges of the [BatchScanner] using `setRanges`.

3. We can make the scan more efficient by only bringing back the columns we want.  Use [fetchColumn] 
to get the `villain` family and `yearsOfService` qualifier.

4. Finally, use the BatchScanner to calculate the average years of service of 2000 villains.

[BatchScanner]: {% jurl org.apache.accumulo.core.client.BatchScanner %}
[createBatchScanner]: {% jurl org.apache.accumulo.core.client.Connector#createBatchScanner-java.lang.String-org.apache.accumulo.core.security.Authorizations-int- %}
[fetchColumn]: {% jurl org.apache.accumulo.core.client.ScannerBase#fetchColumn-org.apache.hadoop.io.Text-org.apache.hadoop.io.Text- %}
