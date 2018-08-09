---
title: Exact Deletes
category: development
order: 10
---

### Overview

In Accumulo's [data model][dm] each row column can have multiple versions and
each version has a timestamp. By default, deletes remove every version in a row
column that is less than or equal to a timestamp. 

### Example

The following example shows the default delete behavior.

```java
    Connector conn = getConnector();
    NewTableConfiguration ntc = new NewTableConfiguration();

    // set wether table has exact deletes, this defaults to false if not set
    ntc.setExactDeleteEnabled(false);

    // only allow deletes with a timestamp
    ntc.setProperties(Collections.singletonMap("table.constraint.1",
        "org.apache.accumulo.core.constraints.NoTimestampDeleteConstraint"));

    // disable versioning iterator that only shows the latest version of a column
    ntc.withoutDefaultIterators();
    conn.tableOperations().create("example1", ntc);

    // insert five versions for the row '02498' and column 'addr:hist'
    try (BatchWriter writer = conn.createBatchWriter("example1")) {
      Mutation mutation = new Mutation("02498");
      mutation.put("addr", "hist", 5L, "5677 Aspen Ave, Springfield, AK");
      mutation.put("addr", "hist", 4L, "3455 Birch Blvd, Springfield, BC");
      mutation.put("addr", "hist", 3L, "1111 Lychee Lane, Springfield, LA");
      mutation.put("addr", "hist", 2L, "1234 Dogwood Dr, Springfield, DE");
      mutation.put("addr", "hist", 1L, "6651 Willow Way, Springfield, WY");
      writer.addMutation(mutation);
    }

    // print if exact deletes are enabled for the table
    System.out.println("Is exact delete enabled : "
        + conn.tableOperations().isExactDeleteEnabled("example1"));

    System.out.println("\nBefore delete : ");
    Scanner scanner = conn.createScanner("example1", Authorizations.EMPTY);
    for (Entry<Key,Value> e : scanner) 
      System.out.println(e.getKey().getTimestamp() + " : " + e.getValue());

    // write out a delete with a timestamp of 3
    try (BatchWriter writer = conn.createBatchWriter("example1")) {
      Mutation mutation = new Mutation("02498");
      mutation.putDelete("addr", "hist", 3L);
      writer.addMutation(mutation);
    }

    System.out.println("\nAfter delete : ");
    for (Entry<Key,Value> e : scanner) 
      System.out.println(e.getKey().getTimestamp() + " : " + e.getValue());

    scanner.close();
```

Below is the output from running the example. Notice the delete with timestamp
3 removed versions 3,2,and 1.

```
Is exact delete enabled : false

Before delete : 
  5 : 5677 Aspen Ave, Springfield, AK
  4 : 3455 Birch Blvd, Springfield, BC
  3 : 1111 Lychee Lane, Springfield, LA
  2 : 1234 Dogwood Dr, Springfield, DE
  1 : 6651 Willow Way, Springfield, WY

After delete : 
  5 : 5677 Aspen Ave, Springfield, AK
  4 : 3455 Birch Blvd, Springfield, BC
```

The behavior of deletes can be changed at table creation time to only delete
the exact version specified by the delete timestamp. This is done by changing
the following line in the example.

```java
    ntc.setExactDeleteEnabled(false);
```

Change the above line to :

```java
    ntc.setExactDeleteEnabled(true);
```

Below is output from running the example with this change. Notice that only
version 3 was deleted and not versions 1 and 2.

```
Is exact delete enabled : true

Before delete : 
  5 : 5677 Aspen Ave, Springfield, AK
  4 : 3455 Birch Blvd, Springfield, BC
  3 : 1111 Lychee Lane, Springfield, LA
  2 : 1234 Dogwood Dr, Springfield, DE
  1 : 6651 Willow Way, Springfield, WY

After delete : 
  5 : 5677 Aspen Ave, Springfield, AK
  4 : 3455 Birch Blvd, Springfield, BC
  2 : 1234 Dogwood Dr, Springfield, DE
  1 : 6651 Willow Way, Springfield, WY
```

### System timestamp for deletes

Deletes can be added to a mutation with no timestamp. When this is done
Accumulo chooses an ever increasing timestamp for the delete. When using exact
deletes, its likely the system chosen timestamp would never correspond to any
existing versions. Therefore not setting the timestamp is likely an error. To
detect this error a table constraint can be set that only allows deletes with a
timestamp. This constraint causes deletes without a timestamp to fail to write.
The example above enabled this constraint with the following lines.

```java
    ntc.setProperties(Collections.singletonMap("table.constraint.1",
        "org.apache.accumulo.core.constraints.NoTimestampDeleteConstraint"));
```

[dm]: {% durl getting-started/design#data-model %}

