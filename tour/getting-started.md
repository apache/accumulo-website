---
title: Getting Started
---

First make sure you have Java, Maven and Git installed on your machine.  Oh you are already rocking? OK let's go!

1. Clone the code repository for the tour onto your machine:
```commandline
git clone -b tour https://github.com/apache/accumulo-website.git tour
cd tour
```
2. Open [Main.java] in your favorite editor.
```commandline
vim ./src/main/java/tour/Main.java
```
Notice the main method creates a [MiniAccumuloCluster] with a root password of "tourpass".  [MiniAccumuloCluster] is a mini
version of Accumulo that runs on your local filesystem.  It should only be used for development purposes but will work
great here on the tour.  Files and logs used by [MiniAccumuloCluster] can be seen in the `target/mac######` directory.

3. Modify the _exercise_ method to print a hello message. You will put your code in this method for each lesson.
    ```java
    static void exercise(AccumuloClient client) {
        // start writing your code here
        System.out.println("Hello world");
    }
    ```
4. Use the following Maven command to build and run the tour.
```commandline
mvn -q clean verify exec:exec
```

[Main.java]: https://github.com/apache/accumulo-website/blob/tour/src/main/java/tour/Main.java
[MiniAccumuloCluster]: {% jurl org.apache.accumulo.minicluster.MiniAccumuloCluster %}
