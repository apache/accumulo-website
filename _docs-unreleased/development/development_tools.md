---
title: Development Tools
category: development
order: 4
---

Normally, Accumulo consists of lots of moving parts. Even a stand-alone version of
Accumulo requires Hadoop, Zookeeper, the Accumulo master, a tablet server, etc. If
you want to write a unit test that uses Accumulo, you need a lot of infrastructure
in place before your test can run.

## Iterator Test Harness

Iterators, while extremely powerful, are notoriously difficult to test. While the API defines
the methods an Iterator must implement and each method's functionality, the actual invocation
of these methods by Accumulo TabletServers can be surprisingly difficult to mimic in unit tests.

The Apache Accumulo "Iterator Test Harness" is designed to provide a generalized testing framework
for all Accumulo Iterators to leverage to identify common pitfalls in user-created Iterators.

### Framework Use

The harness provides an abstract class for use with JUnit4. Users must define the following for this
abstract class:

  * A `SortedMap` of input data (`Key`-`Value` pairs)
  * A `Range` to use in tests
  * A `Map` of options (`String` to `String` pairs)
  * A `SortedMap` of output data (`Key`-`Value` pairs)
  * A list of `IteratorTestCase`s (these can be automatically discovered)

The majority of effort a user must make is in creating the input dataset and the expected
output dataset for the iterator being tested.

### Normal Test Outline

Most iterator tests will follow the given outline:

```java
import java.util.List;
import java.util.SortedMap;

import org.apache.accumulo.core.data.Key;
import org.apache.accumulo.core.data.Range;
import org.apache.accumulo.core.data.Value;
import org.apache.accumulo.iteratortest.IteratorTestCaseFinder;
import org.apache.accumulo.iteratortest.IteratorTestInput;
import org.apache.accumulo.iteratortest.IteratorTestOutput;
import org.apache.accumulo.iteratortest.junit4.BaseJUnit4IteratorTest;
import org.apache.accumulo.iteratortest.testcases.IteratorTestCase;
import org.junit.runners.Parameterized.Parameters;

public class MyIteratorTest extends BaseJUnit4IteratorTest {

  @Parameters
  public static Object[][] parameters() {
    final IteratorTestInput input = createIteratorInput();
    final IteratorTestOutput output = createIteratorOutput();
    final List<IteratorTestCase> testCases = IteratorTestCaseFinder.findAllTestCases();
    return BaseJUnit4IteratorTest.createParameters(input, output, tests);
  }

  private static SortedMap<Key,Value> INPUT_DATA = createInputData();
  private static SortedMap<Key,Value> OUTPUT_DATA = createOutputData();

  private static SortedMap<Key,Value> createInputData() {
    // TODO -- implement this method
  }

  private static SortedMap<Key,Value> createOutputData() {
    // TODO -- implement this method
  }

  private static IteratorTestInput createIteratorInput() {
    final Map<String,String> options = createIteratorOptions(); 
    final Range range = createRange();
    return new IteratorTestInput(MyIterator.class, options, range, INPUT_DATA);
  }

  private static Map<String,String> createIteratorOptions() {
    // TODO -- implement this method
    // Tip: Use INPUT_DATA if helpful in generating output
  }

  private static Range createRange() {
    // TODO -- implement this method
  }

  private static IteratorTestOutput createIteratorOutput() {
    return new IteratorTestOutput(OUTPUT_DATA);
  }
}
```

### Limitations

While the provided `IteratorTestCase`s should exercise common edge-cases in user iterators,
there are still many limitations to the existing test harness. Some of them are:

  * Can only specify a single iterator, not many (a "stack")
  * No control over provided IteratorEnvironment for tests
  * Exercising delete keys (especially with major compactions that do not include all files)

These are left as future improvements to the harness.

## Mock Accumulo

Mock Accumulo supplies mock implementations for much of the client API. It presently
does not enforce users, logins, permissions, etc. It does support Iterators and Combiners.
Note that MockAccumulo holds all data in memory, and will not retain any data or
settings between runs.

While normal interaction with the Accumulo client looks like this:

```java
Instance instance = new ZooKeeperInstance(...);
Connector conn = instance.getConnector(user, passwordToken);
```

To interact with the MockAccumulo, just replace the ZooKeeperInstance with MockInstance:

```java
Instance instance = new MockInstance();
```

In fact, you can use the `--fake` option to the Accumulo shell and interact with
MockAccumulo:

```
$ accumulo shell --fake -u root -p ''

Shell - Apache Accumulo Interactive Shell
-
- version: 2.x.x
- instance name: fake
- instance id: mock-instance-id
-
- type 'help' for a list of available commands
-

root@fake> createtable test

root@fake test> insert row1 cf cq value
root@fake test> insert row2 cf cq value2
root@fake test> insert row3 cf cq value3

root@fake test> scan
row1 cf:cq []    value
row2 cf:cq []    value2
row3 cf:cq []    value3

root@fake test> scan -b row2 -e row2
row2 cf:cq []    value2

root@fake test>
```

When testing Map Reduce jobs, you can also set the Mock Accumulo on the AccumuloInputFormat
and AccumuloOutputFormat classes:

```java
// ... set up job configuration
AccumuloInputFormat.setMockInstance(job, "mockInstance");
AccumuloOutputFormat.setMockInstance(job, "mockInstance");
```

## Mini Accumulo Cluster

While the Mock Accumulo provides a lightweight implementation of the client API for unit
testing, it is often necessary to write more realistic end-to-end integration tests that
take advantage of the entire ecosystem. The Mini Accumulo Cluster makes this possible by
configuring and starting Zookeeper, initializing Accumulo, and starting the Master as well
as some Tablet Servers. It runs against the local filesystem instead of having to start
up HDFS.

To start it up, you will need to supply an empty directory and a root password as arguments:

```java
File tempDirectory = // JUnit and Guava supply mechanisms for creating temp directories
MiniAccumuloCluster accumulo = new MiniAccumuloCluster(tempDirectory, "password");
accumulo.start();
```

Once we have our mini cluster running, we will want to interact with the Accumulo client API:

```java
Instance instance = new ZooKeeperInstance(accumulo.getInstanceName(), accumulo.getZooKeepers());
Connector conn = instance.getConnector("root", new PasswordToken("password"));
```

Upon completion of our development code, we will want to shutdown our MiniAccumuloCluster:

```java
accumulo.stop();
// delete your temporary folder
```
