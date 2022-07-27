---
title: Conditional Writer Code
---

Below is a solution to the exercise.

```commandline
jshell> boolean setAddress(AccumuloClient client, String id, String expectedAddr, String newAddr) {
   ...>   try (ConditionalWriter writer = client.createConditionalWriter("GothamPD", new ConditionalWriterConfig())) {
   ...>     Condition condition = new Condition("location", "home");
   ...>     if (expectedAddr != null) {
   ...>       condition.setValue(expectedAddr);
   ...>     }
   ...>     ConditionalMutation mutation = new ConditionalMutation(id, condition);
   ...>     mutation.put("location", "home", newAddr);
   ...>     return writer.write(mutation).getStatus() == ConditionalWriter.Status.ACCEPTED;
   ...>   } catch (Exception e) {
   ...>     throw new RuntimeException();
   ...>   }
   ...> }
```

The following output shows running the example with a conditional writer.
Threads retry when conditional mutations are rejected.  The final address has
all three modifications.

```commandline
jshell> concurrent_writes()
GothamPD table already exists...proceeding...
Thread  52 attempting change '   1007 Mountain Dr, Gotham, New York  ' -> '1007 Mountain Dr, Gotham, New York'
Thread  91 attempting change '   1007 Mountain Dr, Gotham, New York  ' -> '   1007 Mountain Dr, Gotham, NY  '
Thread  90 attempting change '   1007 Mountain Dr, Gotham, New York  ' -> '   1007 Mountain Dr, Gotham, New York  '
Thread  90 attempting change '1007 Mountain Dr, Gotham, New York' -> '1007 Mountain Dr, Gotham, New York'
Thread  91 attempting change '1007 Mountain Dr, Gotham, New York' -> '1007 Mountain Dr, Gotham, NY'
Final address : '1007 Mountain Dr, Gotham, NY'
```
