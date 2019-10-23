---
title: Conditional Writer Code
---

Below is a solution to the exercise.

```java
  static boolean setAddress(AccumuloClient client, String id, String expectedAddr, String newAddr) {
    try (ConditionalWriter writer = client.createConditionalWriter("GothamPD", new ConditionalWriterConfig())) {
      Condition condition = new Condition("location", "home");
      if(expectedAddr != null) {
        condition.setValue(expectedAddr);
      }
      ConditionalMutation mutation = new ConditionalMutation(id, condition);
      mutation.put("location", "home", newAddr);
      return writer.write(mutation).getStatus() == Status.ACCEPTED;
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

```

The following output shows running the example with a conditional writer.
Threads retry when conditional mutations are rejected.  The final address has
all three modifications.

```
Thread  37 attempting change '  1007 Mountain Drive, Gotham, New York  ' -> '  1007 Mountain Dr, Gotham, New York  '
Thread  38 attempting change '  1007 Mountain Drive, Gotham, New York  ' -> '1007 Mountain Drive, Gotham, New York'
Thread  39 attempting change '  1007 Mountain Drive, Gotham, New York  ' -> '  1007 Mountain Drive, Gotham, NY  '
Thread  38 attempting change '  1007 Mountain Dr, Gotham, New York  ' -> '1007 Mountain Dr, Gotham, New York'
Thread  39 attempting change '  1007 Mountain Dr, Gotham, New York  ' -> '  1007 Mountain Dr, Gotham, NY  '
Thread  39 attempting change '1007 Mountain Dr, Gotham, New York' -> '1007 Mountain Dr, Gotham, NY'
Final address : '1007 Mountain Dr, Gotham, NY'
```
