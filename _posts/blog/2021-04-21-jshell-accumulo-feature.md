---
Title: JShell Accumulo Feature

---

## Overview

First introduced in Java 9, [JShell][jshell-doc] is an interactive Read-Evaluate-Print-Loop (REPL)
Java tool that interprets user's input and outputs the results. This tool provides a convenient
way to test out and execute quick tasks with Accumulo in the terminal. This feature is a part
of the upcoming Accumulo 2.1 release. If you're a developer and want to get involved in testing,
[contact us][contact] or review our [contributing guide][guide].

## Major Features
* Default JShell script provides initial imports for interacting with Accumulo's API and
provided in Accumulo's binary distribution tarball


* On startup, JShell Accumulo  will automatically import the `CLASSPATH`, load in a configured
environment from user's `conf/accumulo-env.sh`, and invoke `conf/jshell-init.jsh`
to allow rapid Accumulo task executions


* JShell Accumulo can startup using default/custom JShell script and users can append any JShell
command-line [options][jshell-option] to the startup command

## Booting Up JShell Accumulo
1) Open up a terminal and navigate to Accumulo's installation directory

2) To startup JShell with **default script** use this command:

```bash
$ bin/accumulo jshell
```
3) To startup JShell with **custom script** use this command:

```bash
$ bin/accumulo jshell --startup file/path/to/custom_script.jsh
```
**Note:** One can execute the `jshell` command to startup JShell. However, doing so will require
manually importing the `CLASSPATH` and the configured environment from `conf/accumulo-env.sh`
and manually specifying the startup file for `conf/jshell-init.jsh` before any Accumulo tasks
can be performed. Using one of the startup commands above will automate that process
for convenience.


## JShell Accumulo Default Script
The auto-generated `jshell-init.jsh` is a customizable file located in Accumulo's installation
`conf/` directory. Inside, `jshell-init.jsh` contains [Accumulo Java APIs][public APIs]
formatted as import statements and [AccumuloClient][client] build implementation. On startup,
the script automatically loads in the APIs and attempts to construct a client. Should additional
APIs and/or code implementations be needed, simply append them to `jshell-init.jsh`.
Alternatively, you can create a separate JShell script and specify the custom script's file path
on startup.

To construct an [AccumuloClient][client], the provided `conf/jshell-init.jsh` script finds
and uses `accumulo-client.properties` in Accumulo's class path, and assigns the result
to a variable called **client**.

If `accumulo-client.properties` is found, a similar result will be produced below:

```
Preparing JShell for Apache Accumulo

Building Accumulo client using 'jar:file:/home/accumulo/lib/accumulo-client.jar!/accumulo-client.properties'

Use 'client' to interact with Accumulo

|  Welcome to JShell -- Version 11.0.10
|  For an introduction type: /help intro

jshell>
```

If `accumulo-client.properties` is not found, an [AccumuloClient][client] will not
auto-generate and will produce the following result below:

```
Preparing JShell for Apache Accumulo

'accumulo-client.properties' was not found on the classpath

|  Welcome to JShell -- Version 11.0.10
|  For an introduction type: /help intro

jshell>
```

## JShell Accumulo Example
1) Booting up JShell Accumulo using default script

```
Preparing JShell for Apache Accumulo

Building Accumulo client using 'file:/home/accumulo/conf/accumulo-client.properties'

Use 'client' to interact with Accumulo

|  Welcome to JShell -- Version 11.0.10
|  For an introduction type: /help intro

jshell>
```

2) Providing JShell with an Accumulo task

```java
  // Create a table called "GothamPD".
  client.tableOperations().create("GothamPD");

  // Create a Mutation object to hold all changes to a row in a table.
  // Each row has a unique row ID.
  Mutation mutation = new Mutation("id0001");

  // Create key/value pairs for Batman. Put them in the "hero" family.
  mutation.put("hero", "alias", "Batman");
  mutation.put("hero", "name", "Bruce Wayne");
  mutation.put("hero", "wearsCape?", "true");

  // Create a BatchWriter to the GothamPD table and add your mutation to it.
  // Try w/ resources will close for us.
  try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
      writer.addMutation(mutation);
  }

  // Read and print all rows of the "GothamPD" table.
  // Try w/ resources will close for us.
  try (ScannerBase scan = client.createScanner("GothamPD", Authorizations.EMPTY)) {
    System.out.println("Gotham Police Department Persons of Interest:");

    // A Scanner is an extension of java.lang.Iterable so behaves just like one.
    scan.forEach((k, v) -> System.out.printf("Key : %-50s Value : %s\n", k, v));
  }
```

**Note:** The fully-qualified class name for Accumulo Scanner or
`org.apache.accumulo.core.client.Scanner` needs to be used due to conflicting issues with
Java's built-in java.util.Scanner. However, to shorten the Accumulo Scanner's declaration, assign
scan to `ScannerBase` type instead.

3) Executing the Accumulo task above outputs:

```
mutation ==> org.apache.accumulo.core.data.Mutation@1
Gotham Police Department Persons of Interest:
Key : id0001 hero:alias [] 1618926204602 false            Value : Batman
Key : id0001 hero:name [] 1618926204602 false             Value : Bruce Wayne
Key : id0001 hero:wearsCape? [] 1618926204602 false       Value : true

jshell>
```
[contact]: /contact-us/
[guide]: /how-to-contribute/
[client]: https://www.javadoc.io/doc/org.apache.accumulo/accumulo-core/latest/org/apache/accumulo/core/client/AccumuloClient.html
[jshell-doc]: https://docs.oracle.com/javase/9/jshell/introduction-jshell.htm#JSHEL-GUID-630F27C8-1195-4989-9F6B-2C51D46F52C8
[jshell-option]: https://docs.oracle.com/javase/9/tools/jshell.htm#JSWOR-GUID-C337353B-074A-431C-993F-60C226163F00
[public APIs]: /api/
