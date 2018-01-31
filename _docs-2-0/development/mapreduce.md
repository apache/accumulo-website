---
title: MapReduce
category: development
order: 2
---

Accumulo tables can be used as the source and destination of MapReduce jobs. To
use an Accumulo table with a MapReduce job, configure the job parameters to use
the [AccumuloInputFormat] and [AccumuloOutputFormat]. Accumulo specific parameters
can be set via these two format classes to do the following:

* Authenticate and provide user credentials for the input
* Restrict the scan to a range of rows
* Restrict the input to a subset of available columns

## Mapper and Reducer classes

To read from an Accumulo table create a Mapper with the following class
parameterization and be sure to configure the [AccumuloInputFormat].

```java
class MyMapper extends Mapper<Key,Value,WritableComparable,Writable> {
    public void map(Key k, Value v, Context c) {
        // transform key and value data here
    }
}
```

To write to an Accumulo table, create a Reducer with the following class
parameterization and be sure to configure the [AccumuloOutputFormat]. The key
emitted from the Reducer identifies the table to which the mutation is sent. This
allows a single Reducer to write to more than one table if desired. A default table
can be configured using the AccumuloOutputFormat, in which case the output table
name does not have to be passed to the Context object within the Reducer.

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

## AccumuloInputFormat options

The following code shows how to set up Accumulo

```java
Job job = new Job(getConf());
ConnectionInfo info = Connector.builder().forInstance("myinstance","zoo1,zoo2")
    .usingPasswordCredentials("user", "passwd").info()
AccumuloInputFormat.setConnectionInfo(job, info);
AccumuloInputFormat.setInputTableName(job, table);
AccumuloInputFormat.setScanAuthorizations(job, new Authorizations());
```

**Optional Settings:**

To restrict Accumulo to a set of row ranges:

```java
ArrayList<Range> ranges = new ArrayList<Range>();
// populate array list of row ranges ...
AccumuloInputFormat.setRanges(job, ranges);
```

To restrict Accumulo to a list of columns:

```java
ArrayList<Pair<Text,Text>> columns = new ArrayList<Pair<Text,Text>>();
// populate list of columns
AccumuloInputFormat.fetchColumns(job, columns);
```

To use a regular expression to match row IDs:

```java
IteratorSetting is = new IteratorSetting(30, RexExFilter.class);
RegExFilter.setRegexs(is, ".*suffix", null, null, null, true);
AccumuloInputFormat.addIterator(job, is);
```

## AccumuloMultiTableInputFormat options

The [AccumuloMultiTableInputFormat] allows the scanning over multiple tables
in a single MapReduce job. Separate ranges, columns, and iterators can be
used for each table.

```java
InputTableConfig tableOneConfig = new InputTableConfig();
InputTableConfig tableTwoConfig = new InputTableConfig();
```

To set the configuration objects on the job:

```java
Map<String, InputTableConfig> configs = new HashMap<String,InputTableConfig>();
configs.put("table1", tableOneConfig);
configs.put("table2", tableTwoConfig);
AccumuloMultiTableInputFormat.setInputTableConfigs(job, configs);
```

**Optional settings:**

To restrict to a set of ranges:

```java
ArrayList<Range> tableOneRanges = new ArrayList<Range>();
ArrayList<Range> tableTwoRanges = new ArrayList<Range>();
// populate array lists of row ranges for tables...
tableOneConfig.setRanges(tableOneRanges);
tableTwoConfig.setRanges(tableTwoRanges);
```

To restrict Accumulo to a list of columns:

```java
ArrayList<Pair<Text,Text>> tableOneColumns = new ArrayList<Pair<Text,Text>>();
ArrayList<Pair<Text,Text>> tableTwoColumns = new ArrayList<Pair<Text,Text>>();
// populate lists of columns for each of the tables ...
tableOneConfig.fetchColumns(tableOneColumns);
tableTwoConfig.fetchColumns(tableTwoColumns);
```

To set scan iterators:

```java
List<IteratorSetting> tableOneIterators = new ArrayList<IteratorSetting>();
List<IteratorSetting> tableTwoIterators = new ArrayList<IteratorSetting>();
// populate the lists of iterator settings for each of the tables ...
tableOneConfig.setIterators(tableOneIterators);
tableTwoConfig.setIterators(tableTwoIterators);
```

The name of the table can be retrieved from the input split:

```java
class MyMapper extends Mapper<Key,Value,WritableComparable,Writable> {
    public void map(Key k, Value v, Context c) {
        RangeInputSplit split = (RangeInputSplit)c.getInputSplit();
        String tableName = split.getTableName();
        // do something with table name
    }
}
```

## AccumuloOutputFormat options

```java
ConnectionInfo info = Connector.builder().forInstance("myinstance","zoo1,zoo2")
    .usingPasswordCredentials("user", "passwd").info()
AccumuloOutputFormat.setConnectionInfo(job, info);
AccumuloOutputFormat.setDefaultTableName(job, "mytable");
```

**Optional Settings:**

```java
AccumuloOutputFormat.setMaxLatency(job, 300000); // milliseconds
AccumuloOutputFormat.setMaxMutationBufferSize(job, 50000000); // bytes
```

The [MapReduce example][mapred-example] contains a complete example of using MapReduce with Accumulo.

[mapred-example]: https://github.com/apache/accumulo-examples/blob/master/docs/mapred.md
[AccumuloInputFormat]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/mapred/AccumuloInputFormat.html
[AccumuloMultiTableInputFormat]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/mapred/AccumuloMultiTableInputFormat.html
[AccumuloOutputFormat]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/mapred/AccumuloOutputFormat.html
