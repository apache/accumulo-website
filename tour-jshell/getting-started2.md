---
title: Getting Started
---

To complete the tour you will need a running Accumulo instance. If you do not have access to an 
Accumulo cluster you can use [fluo-uno] to set up a single node instance for use with the Tour.

Once you have an instance up and running, start the Accumulo JShell interface by typing the command 
below. The '$' represents the system prompt.

```commandline
$ accumulo jshell
```

This will present you with a Java JShell interface with the required Accumulo libraries pre-loaded 
and a working Accumulo ```client``` object.

```commandline
Preparing JShell for Apache Accumulo

Use 'client' to interact with Accumulo

|  Welcome to JShell -- Version 11
|  For an introduction type: /help intro

jshell>
```

JShell has a few commands that can be helpful.

`/imports` lists the currently loaded imports in the JShell session.

```commandline
jshell> /imports
|    import java.io.*
|    import java.math.*
|    import java.net.*
|    import java.nio.file.*
|    import java.util.*
|    import java.util.concurrent.*
|    import java.util.function.*
|    import java.util.prefs.*
|    import java.util.regex.*
|    import java.util.stream.*
|    import org.apache.accumulo.core.client.*
|    import org.apache.accumulo.core.client.admin.*
|    import org.apache.accumulo.core.client.admin.compaction.*
|    import org.apache.accumulo.core.client.lexicoder.*
|    import org.apache.accumulo.core.client.mapred.*
|    import org.apache.accumulo.core.client.mapreduce.*
|    import org.apache.accumulo.core.client.mapreduce.lib.partition.*
|    import org.apache.accumulo.core.client.replication.*
|    import org.apache.accumulo.core.client.rfile.*
|    import org.apache.accumulo.core.client.sample.*
|    import org.apache.accumulo.core.client.security.*
|    import org.apache.accumulo.core.client.security.tokens.*
|    import org.apache.accumulo.core.client.summary.*
|    import org.apache.accumulo.core.client.summary.summarizers.*
|    import org.apache.accumulo.core.data.*
|    import org.apache.accumulo.core.data.constraints.*
|    import org.apache.accumulo.core.security.*
|    import org.apache.accumulo.minicluster.*
|    import org.apache.accumulo.hadoop.mapreduce.*
|    import org.apache.accumulo.hadoop.mapreduce.partition.*
|    import org.apache.hadoop.io.Text
```

`/vars` will display all currently defined variables.

```commandline
jshell> /vars
|    URL clientPropUrl = file:<path_to_accumulo_dir>/conf/accumulo-client.properties
|    AccumuloClient client = org.apache.accumulo.core.clientImpl.ClientContext@7cbee484
```

`/list` displays all user defined code snippets. 

`/list <id>` displays the snippet with the specified id. 

`/list <name>` displays the snippet with the specified name.

`/<id>` will re-run the snippet with the given id. 

For example:

```commandline
jshell> var x = 12;
x ==> 12

jshell> var y = 23;
y ==> 23

jshell> int add(int x, int y) {
   ...>   return x + y;
   ...> }
|  created method add(int,int)

jshell> add(4,5);
$6 ==> 9      

jshell> /list

   1 : System.out.println("Preparing JShell for Apache Accumulo");
   2 : var x = 12;
   3 : var y = 23;
   4 : int add(int x, int y) {
         return x + y;
       }

 jshell> /list add

   5 : int add(int x, int y) {
         return x + y;
       }

jshell> /list 4

   4 : int add(int x, int y) {
         return x + y;
       }
       
jshell> /4
add(4,5);
$8 ==> 9
```

Ok, let's go!

[fluo-uno]: https://github.com/apache/fluo-uno
