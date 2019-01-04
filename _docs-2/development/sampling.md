---
title: Sampling
category: development
order: 5
---

## Overview

Accumulo has the ability to generate and scan a per table set of sample data.
This sample data is kept up to date as a table is mutated.  What key values are
placed in the sample data is configurable per table.

This feature can be used for query estimation and optimization.  For an example
of estimation assume an Accumulo table is configured to generate a sample
containing one millionth of a tables data.   If a query is executed against the
sample and returns one thousand results, then the same query against all the
data would probably return a billion results.  A nice property of having
Accumulo generate the sample is that its always up to date.  So estimations
will be accurate even when querying the most recently written data.

An example of a query optimization is an iterator using sample data to get an
estimate, and then making decisions based on the estimate.

## Configuring

In order to use sampling, an Accumulo table must be configured with a class that
implements [Sampler] along with options for that class.  For guidance on
implementing a Sampler, see the [Sampler interface javadoc][Sampler]. Accumulo provides a few
implementations of Sampler out of the box. For information on how to use the samplers that
ship with Accumulo, look in the package [org.apache.accumulo.core.client.sample][sample-package]
and consult the javadoc of the classes there. See the [sampling example][example]
for examples of how to configure a [Sampler] on a table.

Once a table is configured with a [Sampler], all writes after that point will
generate sample data.  For data written before sampling was configured, sample
data will not be present.  A compaction can be initiated that only compacts the
files in the table that do not have sample data.  The [sampling example][example] 
shows how to do this.

If the sampling configuration of a table is changed, then Accumulo will start
generating new sample data with the new configuration.   However old data will
still have sample data generated with the previous configuration.  A selective
compaction can also be issued in this case to regenerate the sample data.

## Scanning sample data

In order to scan sample data, use `setSamplerConfiguration(...)` method of
[Scanner] or [BatchScanner].  Please consult the javadoc of this method for more
information.

Sample data can also be scanned from within an Accumulo [SortedKeyValueIterator][skv-iterator].
To see how to do this, look at the example iterator referenced in the [sampling example][example].
Also, consult the javadoc on [IteratorEnvironment.cloneWithSamplingEnabled()][clone-sampling].

MapReduce jobs using the [AccumuloInputFormat] can also read sample data.  See the javadoc
for `samplerConfiguration()` in the `configure()` method of [AccumuloInputFormat].

Scans over sample data will throw a [SampleNotPresentException] in the following cases :

1. sample data is not present,
2. sample data is present but was generated with multiple configurations
3. sample data is partially present

So a scan over sample data can only succeed if all data written has sample data
generated with the same configuration.

## Bulk import

When generating rfiles to bulk import into Accumulo, those rfiles can contain
sample data.  To use this feature, look at the javadoc of `sampler()` in the `configure()`
method of [AccumuloFileOutputFormat].

[example]: https://github.com/apache/accumulo-examples/blob/master/docs/sample.md
[Sampler]: {% jurl org.apache.accumulo.core.client.sample.Sampler %}
[sample-package]: {% jurl org.apache.accumulo.core.client.sample %}
[skv-iterator]: {% jurl org.apache.accumulo.core.iterators.SortedKeyValueIterator %}
[clone-sampling]: {% jurl org.apache.accumulo.core.iterators.IteratorEnvironment#cloneWithSamplingEnabled-- %}
[AccumuloInputFormat]: {% jurl org.apache.accumulo.hadoop.mapreduce.AccumuloInputFormat %}
[AccumuloFileOutputFormat]: {% jurl org.apache.accumulo.hadoop.mapreduce.AccumuloFileOutputFormat %}
[SampleNotPresentException]: {% jurl org.apache.accumulo.core.client.SampleNotPresentException %}
[BatchScanner]: {% jurl org.apache.accumulo.core.client.BatchScanner %}
[Scanner]: {% jurl org.apache.accumulo.core.client.Scanner %}
