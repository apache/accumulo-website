Accumulo Tour
---------

This git repository provides a barebones Maven+Java environment for the [Accumulo Tour][tour].  As you
go through the tour edit [Main.java] and use the following maven command to run your code.  This command 
will execute Main.java with all of the correct dependencies on the classpath.

```bash
mvn -q clean compile exec:java
```

The command takes a bit to run because it starts a MiniAccumulo each time.

[tour]: https://fluo.apache.org/tour
[Main.java]: src/main/java/tour/Main.java

