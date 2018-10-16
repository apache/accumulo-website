---
title: Development Tools
category: development
order: 4
---

Accumulo has several tools that can help developers test their code.

## MiniAccumuloCluster

[MiniAccumuloCluster] is a standalone instance of Apache Accumulo for testing. It will
create Zookeeper and Accumulo processes that write all of their data to a single local
directory. [MiniAccumuloCluster] makes it easy to code against a real Accumulo instance.
Developers can write realistic-to-end integration tests that mimic the use of a normal
Accumulo instance.

[MiniAccumuloCluster] is published in a separate jar that should be added to your pom.xml
as a test dependency:

```xml
<dependency>
  <groupId>org.apache.accumulo</groupId>
  <artifactId>accumulo-minicluster</artifactId>
  <version>${accumulo.version}</version>
  <scope>test</scope>
</dependency>
```

To start it up, you will need to supply an empty directory and a root password as arguments:

```java
File tempDirectory = // JUnit and Guava supply mechanisms for creating temp directories
MiniAccumuloCluster mac = new MiniAccumuloCluster(tempDirectory, "password");
mac.start();
```

Once we have our mini cluster running, we will want to interact with the Accumulo client API:

```java
AccumuloClient client = mac.getAccumuloClient("root", new PasswordToken("password"));
```

Upon completion of our development code, we will want to shutdown our MiniAccumuloCluster:

```java
mac.stop();
// delete your temporary folder
```

## Iterator Test Harness

Iterators, while extremely powerful, are notoriously difficult to test. While the API defines
the methods an Iterator must implement and each method's functionality, the actual invocation
of these methods by Accumulo TabletServers can be surprisingly difficult to mimic in unit tests.

The Apache Accumulo "Iterator Test Harness" is designed to provide a generalized testing framework
for all Accumulo Iterators to leverage to identify common pitfalls in user-created Iterators.

### Framework Use

The Iterator Test Harness is published in a separate jar that should be added to your pom.xml as
a test dependency:

```xml
<dependency>
  <groupId>org.apache.accumulo</groupId>
  <artifactId>accumulo-iterator-test-harness</artifactId>
  <version>${accumulo.version}</version>
  <scope>test</scope>
</dependency>
```

To use the Iterator test harness, create a class that extends the [BaseJUnit4IteratorTest] class
and defines the following:

  * A `SortedMap` of input data (`Key`-`Value` pairs)
  * A [Range] to use in tests
  * A `Map` of options (`String` to `String` pairs)
  * A `SortedMap` of output data (`Key`-`Value` pairs)
  * A list of [IteratorTestCase]s (these can be automatically discovered)

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

While the provided [IteratorTestCase]s should exercise common edge-cases in user iterators,
there are still many limitations to the existing test harness. Some of them are:

  * Can only specify a single iterator, not many (a "stack")
  * No control over provided IteratorEnvironment for tests
  * Exercising delete keys (especially with major compactions that do not include all files)

These are left as future improvements to the harness.

[Range]: {% jurl org.apache.accumulo.core.data.Range %}
[IteratorTestCase]: {% jurl org.apache.accumulo.iteratortest.testcases.IteratorTestCase %}
[BaseJUnit4IteratorTest]: {% jurl org.apache.accumulo.iteratortest.junit4.BaseJUnit4IteratorTest %}
[MiniAccumuloCluster]: {% jurl org.apache.accumulo.minicluster.MiniAccumuloCluster %}
