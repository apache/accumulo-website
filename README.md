Accumulo Tour
---------

This git repository provides a barebones Maven+Java environment for the [Accumulo Tour][tour].  As you
go through the tour edit [Main.java] and use the following maven command to run your code.  This command 
will execute Main.java with all of the correct dependencies on the classpath.

```commandline
mvn -q clean compile exec:java
```

The command takes a bit to run because it starts a MiniAccumuloCluster each time.

MiniAccumuloCluster is a mini version of Accumulo that runs on your local filesystem.  It should only be used for
development purposes. Files and logs used by MiniAccumuloCluster can be seen in the generated directory:

```commandline
target/mac########
```

Running _mvn clean_ will remove any files created by previous runs.

[tour]: https://fluo.apache.org/tour
[Main.java]: src/main/java/tour/Main.java