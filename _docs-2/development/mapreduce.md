---
title: MapReduce
category: development
order: 2
---

Accumulo tables can be used as the source and destination of MapReduce jobs.

## General MapReduce configuration

Since 2.0.0, Accumulo no longer has the same dependency versions (i.e Guava, etc) as Hadoop.
When launching a MapReduce job that reads or writes to Accumulo, you should build a shaded jar
with all of your dependencies and complete the following steps so YARN only includes Hadoop code
(and not all of Hadoop dependencies) when running your MapReduce job:

1. Set `export HADOOP_USE_CLIENT_CLASSLOADER=true` in your environment before submitting
   your job with `yarn` command.

2. Set the following in your Job configuration.
    ```java
    job.getConfiguration().set("mapreduce.job.classloader", "true");
    ```

## Read input from an Accumulo table

Follow the steps below to create a MapReduce job that reads from an Accumulo table:

1. Create a Mapper with the following class parameterization.

    ```java
    class MyMapper extends Mapper<Key,Value,WritableComparable,Writable> {
        public void map(Key k, Value v, Context c) {
            // transform key and value data here
        }
    }
    ```

2. Configure your MapReduce job to use [AccumuloInputFormat].

    ```java
    Job job = Job.getInstance(getConf());
    job.setInputFormatClass(AccumuloInputFormat.class);
    Properties props = Accumulo.newClientProperties().to("myinstance","zoo1,zoo2")
                            .as("user", "passwd").build();
    AccumuloInputFormat.configure().clientProperties(props).table(table).store(job);
    ```
    [AccumuloInputFormat] has optional settings.
    ```java
    List<Range> ranges = new ArrayList<Range>();
    List<Pair<Text,Text>> columns = new ArrayList<Pair<Text,Text>>();
    // populate ranges & columns
    IteratorSetting is = new IteratorSetting(30, RexExFilter.class);
    RegExFilter.setRegexs(is, ".*suffix", null, null, null, true);

    AccumuloInputFormat.configure().clientProperties(props).table(table)
        .auths(Authorizations.EMPTY) // optional: default to user's auths if not set
        .ranges(ranges)              // optional: only read specified ranges
        .fetchColumns(columns)       // optional: only read specified columns
        .addIterator(is)             // optional: add iterator that matches row IDs
        .store(job);
    ```
    [AccumuloInputFormat] can also be configured to read from multiple Accumulo tables.
    ```java
    Job job = Job.getInstance(getConf());
    job.setInputFormatClass(AccumuloInputFormat.class);
    Properties props = Accumulo.newClientProperties().to("myinstance","zoo1,zoo2")
                            .as("user", "passwd").build();
    AccumuloInputFormat.configure().clientProperties(props)
        .table("table1").auths(Authorizations.EMPTY).ranges(tableOneRanges)
        .table("table2").auths(Authorizations.EMPTY).ranges(tableTwoRanges)
        .store(job);
    ```
    If reading from multiple tables, the table name can be retrieved from the input split:
    ```java
    class MyMapper extends Mapper<Key,Value,WritableComparable,Writable> {
        public void map(Key k, Value v, Context c) {
            RangeInputSplit split = (RangeInputSplit)c.getInputSplit();
            String tableName = split.getTableName();
            // do something with table name
        }
    }
    ```

## Write output to an Accumulo table

Follow the steps below to write to an Accumulo table from a MapReduce job.

1. Create a Reducer with the following class parameterization. The key emitted from
    the Reducer identifies the table to which the mutation is sent. This allows a single
    Reducer to write to more than one table if desired. A default table can be configured
    using the [AccumuloOutputFormat], in which case the output table name does not have to
    be passed to the Context object within the Reducer.
    ```java
    class MyReducer extends Reducer<WritableComparable, Writable, Text, Mutation> {
        public void reduce(WritableComparable key, Iterable<Text> values, Context c) {
            Mutation m;
            // create the mutation based on input key and value
            c.write(new Text("output-table"), m);
        }
    }
    ```
    The Text object passed as the output should contain the name of the table to which
    this mutation should be applied. The Text can be null in which case the mutation
    will be applied to the default table name specified in the [AccumuloOutputFormat]
    options.

2. Configure your MapReduce job to use [AccumuloOutputFormat].
    ```java
    Job job = Job.getInstance(getConf());
    job.setOutputFormatClass(AccumuloOutputFormat.class);
    Properties props = Accumulo.newClientProperties().to("myinstance","zoo1,zoo2")
                            .as("user", "passwd").build();
    AccumuloOutputFormat.configure().clientProperties(props)
        .defaultTable("mytable").store(job);
    ```

The [MapReduce example][mapred-example] contains a complete example of using MapReduce with Accumulo.

[mapred-example]: https://github.com/apache/accumulo-examples/blob/master/docs/mapred.md
[AccumuloInputFormat]: {% jurl org.apache.accumulo.hadoop.mapreduce.AccumuloInputFormat %}
[AccumuloOutputFormat]: {% jurl org.apache.accumulo.hadoop.mapreduce.AccumuloOutputFormat %}
