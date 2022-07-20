---
title: Conditional Writer
---

Suppose the Gotham PD is storing home addresses for persons of interest in
Accumulo.  We want to correctly handle the case of multiple users editing the
same address at the same time. The following sequence of events shows an example
of how this can go wrong.

 1. User 0 sets the key `id0001:location:home` to `1007 Mountain Drive, Gotham, New York`
 2. User 1 reads `id0001:location:home`
 3. User 2 reads `id0001:location:home`
 4. User 1 replaces `Drive` with `Dr`
 5. User 2 replaces `New York` with `NY`
 6. User 1 sets key `id0001:location:home` to `1007 Mountain Dr, Gotham, New York`
 7. User 2 sets key `id0001:location:home` to `1007 Mountain Drive, Gotham, NY`

In this situation the changes made by User 1 are lost, ending up with `1007
Mountain Drive, Gotham, NY` instead of `1007 Mountain Dr, Gotham, New York`.  To
correctly handle this, Accumulo offers the [ConditionalWriter].  The
ConditionalWriter atomically checks conditions on a row and only applies a
mutation when all conditions are satisfied.

## Exercise

The following code simulates the concurrency in the situation above.  The code
starts multiple threads, with each thread doing the following.

 1. Read key's value into memory using a scanner
 2. Modify the copy in memory.
 3. Write out the modified value from memory using a batch writer.
 4. If write was unsuccessful, then goto step 1.

This process can result in threads overwriting each other's changes.  The problem is the batch writer 
always makes the update, even when the value has changed since it was read.

To simplify, we will create several small methods to illustrate the issue.

```commandline
jshell> String getAddress(AccumuloClient client, String id)  {
    ...>   try (org.apache.accumulo.core.client.Scanner scan = new IsolatedScanner(client.createScanner("GothamPD", Authorizations.EMPTY))) {
    ...>     scan.setRange(Range.exact(id, "location", "home"));
    ...>     for (Map.Entry<Key, Value> entry : scan) {
    ...>       return entry.getValue().toString();
    ...>     }
    ...>     return null;
    ...>   } catch (TableNotFoundException e) {
    ...>     throw new RuntimeException(e);
    ...>   }
    ...> }
    |  created method getAddress(AccumuloClient,String)


jshell> boolean setAddress(AccumuloClient client, String id, String expectedAddr, String newAddr) {
   ...>   try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
   ...>     Mutation mutation = new Mutation(id);
   ...>     mutation.put("location", "home", newAddr);
   ...>     writer.addMutation(mutation);
   ...>     return true;
   ...>   } catch (Exception e) {
   ...>     throw new RuntimeException(e);
   ...>   }
   ...> }
|  created method setAddress(AccumuloClient,String,String,String)


jshell> Future<Void> modifyAddress(AccumuloClient client, String id, Function<String,String> modifier) throws Exception {
   ...>   return CompletableFuture.runAsync(() -> {
   ...>     String currAddr, newAddr;
   ...>     do {
   ...>       currAddr = getAddress(client, id);
   ...>       newAddr = modifier.apply(currAddr);
   ...>       System.out.printf("Thread %3d attempting change %20s -> %-20s\n",
   ...>       Thread.currentThread().getId(), "'"+currAddr+"'", "'"+newAddr+"'");
   ...>     } while (!setAddress(client, id, currAddr, newAddr));
   ...>   });
   ...> }
|  created method modifyAddress(AccumuloClient,String,Function<String,String>)

        
jshell> void concurrent_writes() throws Exception {
   ...>   try {
   ...>     client.tableOperations().create("GothamPD");
   ...>   } catch (TableExistsException e) {
   ...>     System.out.println("GothamPD table already exists...proceeding...");
   ...>   }
   ...>   String id = "id0001";
   ...>   setAddress(client, id, null, "   1007 Mountain Drive, Gotham, New York  ");
   ...>   Future<Void> future1 = modifyAddress(client, id, String::trim);
   ...>   Future<Void> future2 = modifyAddress(client, id, addr -> addr.replace("Drive", "Dr"));
   ...>   Future<Void> future3 = modifyAddress(client, id, addr -> addr.replace("New York", "NY"));
   ...>   future1.get();
   ...>   future2.get();
   ...>   future3.get();
   ...>   System.out.println("Final address : '" + getAddress(client, id) + "'");
   ...> }
|  created method concurrent_writes()

```

The following is one of a few possible outputs.  Notice that only the
modification of `Drive` to `Dr` shows up in the final output.  The other
modifications were lost.

```commandline
jshell> concurrent_writes()
GothamPD table already exists...proceeding...
Thread  52 attempting change '   1007 Mountain Drive, Gotham, New York  ' -> '   1007 Mountain Drive, Gotham, NY  '
Thread  38 attempting change '   1007 Mountain Drive, Gotham, New York  ' -> '1007 Mountain Drive, Gotham, New York'
Thread  53 attempting change '   1007 Mountain Drive, Gotham, New York  ' -> '   1007 Mountain Dr, Gotham, New York  '
Final address : '   1007 Mountain Dr, Gotham, New York  '

```

To fix this example, make the following changes in `setAddress()` to use a
ConditionalWriter.

 * Call [createConditionalWriter] instead of creating a batch writer
 * Create a [Condition] for the column 'location:home'.  If `expectedAddr` is not null, then call [setValue] passing `expectedAddr`.  If `expectedAddr` is null, then do nothing else with the condition. A condition with no value means that column is expected to be absent.
 * Replace Mutation with a [ConditionalMutation] and pass the condition to its constructor.
 * Call [write] passing it the conditional mutation.
 * Return `true` if [getStatus] from the [Result] returned by [write] is [ACCEPTED].

[ConditionalWriter]: {% jurl org.apache.accumulo.core.client.ConditionalWriter %}
[Result]: {% jurl org.apache.accumulo.core.client.ConditionalWriter.Result %}
[createConditionalWriter]: {% jurl org.apache.accumulo.core.client.Connector#createConditionalWriter-java.lang.String-org.apache.accumulo.core.client.ConditionalWriterConfig- %}
[Condition]: {% jurl org.apache.accumulo.core.data.Condition %}
[ConditionalMutation]: {% jurl org.apache.accumulo.core.data.ConditionalMutation %}
[getStatus]: {% jurl org.apache.accumulo.core.client.ConditionalWriter.Result#getStatus-- %}
[write]: {% jurl org.apache.accumulo.core.client.ConditionalWriter#write-org.apache.accumulo.core.data.ConditionalMutation- %}
[setValue]: {% jurl org.apache.accumulo.core.data.Condition#setValue-java.lang.CharSequence- %}
[ACCEPTED]: {% jurl org.apache.accumulo.core.client.ConditionalWriter.Status#ACCEPTED %}
