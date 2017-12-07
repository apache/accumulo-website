---
title: Conditional Writer
---

When read-modify-write operations run concurrently, its possible changes made
by some operations will be overwritten by others. The following sequence of
events shows an example of this.

 1. Thread 0 sets the key `id0001:location:home` to `1007 Mountain Dr, Gotham, New York`
 2. Thread 1 reads `id0001:location:home`
 3. Thread 2 reads `id0001:location:home`
 4. Thread 1 replaces `Dr` with `Drive`
 5. Thread 2 replaces `New York` with `NY`
 6. Thread 1 sets key `id0001:location:home` to `1007 Mountain Drive, Gotham, New York`
 7. Thread 2 sets key `id0001:location:home` to `1007 Mountain Dr, Gotham, NY`

In this situation the changes made by Thread 1 are lost, ending up with `1007
Mountain Dr, Gotham, NY` instead of `1007 Mountain Drive, Gotham, NY`.  To
correctly handle this, Accumulo offers the [ConditionalWriter].  The
ConditionalWriter atomically checks conditions on a row and only applies a
mutation when all are satisfied.

## Exercise

The following code simulates the concurrency situation above.  Because it uses
a BatchWriter it will lose modifications.

```java
  static String getAddress(Connector conn, String id) {
    // The IsolatedScanner ensures partial changes to a row are not seen
    try (Scanner scanner = new IsolatedScanner(conn.createScanner("GothamPD", Authorizations.EMPTY))) {
      scanner.setRange(Range.exact(id, "location", "home"));
      for (Entry<Key,Value> entry : scanner) {
        return entry.getValue().toString();
      }
      return null;
    } catch (TableNotFoundException e) {
      throw new RuntimeException(e);
    }
  }

  static boolean setAddress(Connector conn, String id, String expectedAddr, String newAddr) {
    try (BatchWriter writer = conn.createBatchWriter("GothamPD", new BatchWriterConfig())) {
      Mutation mutation = new Mutation(id);
      mutation.put("location", "home", newAddr);
      writer.addMutation(mutation);
      return true;
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  public static Future<Void> modifyAddress(Connector conn, String id, Function<String,String> modifier) {
    return CompletableFuture.runAsync(() -> {
      String currAddr, newAddr;
      do {
        currAddr = getAddress(conn, id);
        newAddr = modifier.apply(currAddr);
        System.out.printf("Thread %3d attempting change %20s -> %-20s\n",
            Thread.currentThread().getId(), "'"+currAddr+"'", "'"+newAddr+"'");
      } while (!setAddress(conn, id, currAddr, newAddr));
    });
  }

  static void exercise(MiniAccumuloCluster mac) throws Exception {
    Connector conn = mac.getConnector("root", "tourguide");
    conn.tableOperations().create("GothamPD");

    String id = "id0001";

    setAddress(conn, id, null, "  1007 Mountain Dr, Gotham, New York  ");

    // create async operation to trim whitespace
    Future<Void> future1 = modifyAddress(conn, id, String::trim);

    // create async operation to replace Dr with Drive
    Future<Void> future2 = modifyAddress(conn, id, addr -> addr.replace("Dr", "Drive"));

    // create async operation to replace New York with NY
    Future<Void> future3 = modifyAddress(conn, id, addr -> addr.replace("New York", "NY"));

    // wait for async operations to complete
    future1.get();
    future2.get();
    future3.get();

    // print the address stored in Accumulo
    System.out.println("Final address : '"+getAddress(conn, id)+"'");
  }
```

The following is one of a few possible outputs.  Notice that only the
modification of `New York` to `NY` shows up in the final output.  The other
modifications were lost.

```
Thread  38 attempting change '  1007 Mountain Dr, Gotham, New York  ' -> '  1007 Mountain Drive, Gotham, New York  '
Thread  39 attempting change '  1007 Mountain Dr, Gotham, New York  ' -> '  1007 Mountain Dr, Gotham, NY  '
Thread  37 attempting change '  1007 Mountain Dr, Gotham, New York  ' -> '1007 Mountain Dr, Gotham, New York'
Final address : '  1007 Mountain Dr, Gotham, NY  '
```

To fix this example, make the following changes in `setAddress()` to use a
ConditionalWriter.

 * Call [createConditionalWriter] instead of creating a batch writer
 * Create a [Condition] for the column 'location:home'.  If `expectedAddr` is not null, then pass it to [setValue].  A condition with no value set means that column is expected to absent.
 * Replace Mutation with a [ConditionalMutation] and set the condition.
 * Call [write] passing it the conditional mutation.
 * Return `true` if [getStatus] from the [Result] returned by [write] is `ACCEPTED`. 

[ConditionalWriter]: {{ site.javadoc_core }}/org/apache/accumulo/core/client/ConditionalWriter.html
[Result]: {{ site.javadoc_core }}/org/apache/accumulo/core/client/ConditionalWriter.Result.html
[createConditionalWriter]: {{ site.javadoc_core }}/org/apache/accumulo/core/client/Connector.html#createConditionalWriter(java.lang.String,%20org.apache.accumulo.core.client.ConditionalWriterConfig)
[Condition]: {{ site.javadoc_core }}/org/apache/accumulo/core/data/Condition.html
[ConditionalMutation]: {{ site.javadoc_core }}/org/apache/accumulo/core/data/ConditionalMutation.html
[getStatus]: {{ site.javadoc_core }}/org/apache/accumulo/core/client/ConditionalWriter.Result.html#getStatus()
[write]: {{ site.javadoc_core }}/org/apache/accumulo/core/client/ConditionalWriter.html#write(org.apache.accumulo.core.data.ConditionalMutation)
[setValue]: {{ site.javadoc_core }}/org/apache/accumulo/core/data/Condition.html#setValue(java.lang.CharSequence)
