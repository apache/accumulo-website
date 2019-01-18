---
title: Batch Scanner Code
---

Below is a solution to the exercise.

```java
static void exercise(MiniAccumuloCluster mac) throws Exception {

  // Create an AccumuloClient to Mini Accumulo
  try (AccumuloClient client = Accumulo.newClient().from(mac.getClientProperties()).build()) {

    // Create the GothamPD table
    client.tableOperations().create("GothamPD");

    // Generate 10,000 rows of henchman data, each with a different number for yearsOfService
    try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
      for (int i = 0; i < 10_000; i++) {
        Mutation m = new Mutation(String.format("id%04d", i));
        m.at().family("villain").qualifier("alias").put("henchman" + i);
        m.at().family("villain").qualifier("yearsOfService").put("" + (new Random().nextInt(50)));
        m.at().family("villain").qualifier("wearsCape?").put("false");
        writer.addMutation(m);
      }
    }

    try (BatchScanner batchScanner = client.createBatchScanner("GothamPD", Authorizations.EMPTY)) {
      // 2. Create a collection of 2 sample ranges and set it to the batchScanner
      List ranges = new ArrayList<Range>();
      ranges.add(new Range("id1000", "id1999"));
      ranges.add(new Range("id9000", "id9999"));
      batchScanner.setRanges(ranges);

      // 3. Fetch just the columns we want
      batchScanner.fetchColumn(new Text("villain"), new Text("yearsOfService"));

      // 4. Calculate average years of service
      Long totalYears = 0L;
      Long entriesRead = 0L;
      for (Map.Entry<Key, Value> entry : batchScanner) {
        totalYears += Long.valueOf(entry.getValue().toString());
        entriesRead++;
      }
      System.out.println("The average years of service of " + entriesRead + " villians is " + totalYears / entriesRead);
    }
  }
}
```

Running the solution above should print output similar to below:

```
The average years of service of 2000 villians is 24
```
