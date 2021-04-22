---
Title: JShell Accumulo Feature
Author: R. Dane Magbuhos
Reviewers: Christopher Tubbs, Keith Turner
---

## Overview
First introduced in Java 9+, [JShell][JShell Doc] is an interactive Read-Evaluate-Print-Loop (REPL) 
Java tool that assess user's inputed declarations, statements, and expressions and outputs 
the results. This tool provides a convenient way to test out and execute quick tasks with Accumulo
in the terminal.

## Major Features
* During Accumulo build, produces a default JShell script called `jshell-init.jsh` 
containing up-to-date [Accumulo Java APIs][public APIs] and [AccumuloClient][client] 
build implementation

* Startup JShell with default or custom JShell script 

* Both JShell start up options automatically import all relevant Java APIs 

## Booting Up JShell Accumulo
After installing and configuring the [latest Accumulo update][accumulo-repo]
follow the steps below to startup JShell:

1) Open up a terminal and navigate to Accumulo's home directory 

2) To startup JShell with **default script** use this command:

```bash
$ bin/accumulo jshell 
```
3) To startup JShell with **custom script** use this command:

```bash
$ bin/accumulo jshell --startup (file/path/to/custom_script.jsh)
```
## JShell Accumulo Default Script
The auto-generated `jshell-init.jsh` is located in Accumulo's `conf/` directory. 
Inside `jshell-init.jsh` contains [Accumulo Java APIs][public APIs] formatted as import statements 
and [AccumuloClient][client] build implementation. On startup the script automatically loads in the 
APIs and attempts to construct a client. Should additional APIs and/or code implementations be 
needed, simply append them to `jshell-init.jsh`. Alternatively you can create a separate JShell 
script and specify the custom script's file path on startup.

The build implementation finds and uses `accumulo-client.properties` in Accumulo's 
classpath to auto-generate an [AccumuloClient][client] called **client**. 
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
1) Booting up JShell using default script

```
Preparing JShell for Apache Accumulo 

Building Accumulo client using 'file:/home/accumulo/conf/accumulo-client.properties'

Use 'client' to interact with Accumulo

|  Welcome to JShell -- Version 11.0.10
|  For an introduction type: /help intro

jshell> 
```

2) Providing JShell with an Accumulo task

```Java
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
  try (org.apache.accumulo.core.client.Scanner scan =
    client.createScanner("GothamPD", Authorizations.EMPTY)) {
    System.out.println("Gotham Police Department Persons of Interest:");
    
    // A Scanner is an extension of java.lang.Iterable so behaves just like one.
    for (Map.Entry<Key,Value> entry : scan) {
      System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
    }
  }
```

3) Executing the Accumulo task above outputs:

```
mutation ==> org.apache.accumulo.core.data.Mutation@1
Gotham Police Department Persons of Interest:
Key : id0001 hero:alias [] 1618926204602 false            Value : Batman
Key : id0001 hero:name [] 1618926204602 false             Value : Bruce Wayne
Key : id0001 hero:wearsCape? [] 1618926204602 false       Value : true

jshell>
```

[accumulo-repo]: https://github.com/apache/accumulo
[client]: https://www.javadoc.io/doc/org.apache.accumulo/accumulo-core/latest/org/apache/accumulo/core/client/AccumuloClient.html
[JShell Doc]: https://docs.oracle.com/javase/9/jshell/introduction-jshell.htm#JSHEL-GUID-630F27C8-1195-4989-9F6B-2C51D46F52C8
[public APIs]: https://accumulo.apache.org/api/