---
title: Related Projects
permalink: /related-projects/
redirect_from: /projects
---

The Apache Accumulo community is happy to promote and encourage use of Accumulo in ways that are novel and reusable
by other users within the community. As such, we're happy to curate a list of projects related to Accumulo to give
them visibility to a larger audience. The following list is provided without endorsement.

To request a new listing here, email the [developer's mailing list](mailto:dev@accumulo.apache.org)
or [edit this page and create a pull request](https://github.com/apache/accumulo-website/edit/master/pages/related-projects.md).

## Open source projects using Accumulo

#### Apache Fluo

[Fluo](https://fluo.apache.org) builds on Accumulo and enables low latency, continuous incremental processing of big data.

#### Apache Gora

[Gora](https://gora.apache.org/) open source framework provides an in-memory data model and persistence for big data.  Accumulo's continuous ingest test suite was adapted to Gora and called [Goraci](https://gora.apache.org/current/index.html#goraci-integration-testsing-suite).

#### Apache Hive

[Hive](https://hive.apache.org/) data warehouse software facilitates reading, writing, and managing large datasets residing in distributed storage using SQL.
Hive has the ability to read and write data in Accumulo using the [AccumuloStorageHandler](https://cwiki.apache.org/confluence/display/Hive/AccumuloIntegration).

#### Apache Pig

[Pig](https://pig.apache.org/) is a platform for analyzing large data sets that consists of a high-level language for expressing data analysis programs, coupled with infrastructure for evaluating these programs.  Pig has the ability to read and write data in Accumulo using [AccumuloStorage](https://pig.apache.org/docs/r0.16.0/func.html#AccumuloStorage).

#### Apache Rya

[Rya](https://rya.apache.org/) is a scalable RDF triple store built on top of a columnar index store.

#### D4M

[D4M](https://d4m.mit.edu/) is an open source library for large-scale computation that supports graph, matrix, and relational processing. D4M includes an Accumulo connector, among others, to interface with and compute on data in Accumulo tables.

#### Gaffer

[Gaffer](https://github.com/gchq/Gaffer) is an open source framework for constructing and querying very large graphs based on a variety of data storage platforms, including Accumulo.

#### Geomesa

[Geomesa](http://www.geomesa.org/) is an open-source, distributed, spatio-temporal database built on a number of distributed cloud data storage systems, including Accumulo, HBase, Cassandra, and Kafka.

#### Geowave

[Geowave](https://ngageoint.github.io/geowave/) is a library for storage, index, and search of multi-dimensional data on top of a sorted key-value datastore.

#### Graphulo

[Graphulo](https://github.com/Accla/graphulo) is a Java library for Apache Accumulo which delivers server-side sparse matrix math primitives that
enable higher-level graph algorithms and analytics.

#### Presto

[Presto](https://prestodb.io/) is an open source distributed SQL query engine for running interactive analytic queries against data sources of all sizes, ranging from gigabytes to petabytes.  Through the use of the new Accumulo connector for Presto, users are able to execute traditional SQL queries against new and existing tables in Accumulo.  For more information, see the [Accumulo Connector](https://prestodb.io/docs/current/connector/accumulo.html) documentation.

#### Sharkbite

[Sharkbite](https://github.com/phrocker/sharkbite/) is a native Key/Value client that supports direct Accumulo access without the need for a proxy.

#### Timely

[Timely](https://nationalsecurityagency.github.io/timely/) is a secure time series database based on Accumulo and Grafana.

#### Uno and Muchos

[Uno](https://github.com/apache/fluo-uno) and [Muchos](https://github.com/apache/fluo-muchos) provide automation for quickly setting up Accumulo instances for testing.  These project were created to enable Fluo testing, but can be used to setup just Accumulo.

## User-Created Applications

#### Trendulo

[Trendulo](http://trendulo.com/) is Twitter trend analysis using Apache Accumulo. The [source code](https://github.com/jaredwinick/Trendulo) is publicly available.

#### Wikisearch

[Wikisearch](https://github.com/apache/accumulo-wikisearch) is a rough example of generalized secondary indexing, both ingest
and search, built on top of Apache Accumulo. This write contains more information on the project as well as some
general performance numbers of the project.

#### Node.js, RabbitMQ, and Accumulo

A [simple example](https://github.com/joshelser/node-accumulo) using Node.js to interact with Accumulo using RabbitMQ .

#### ProxyInstance

ProxyInstance is a Java Instance implementation of the Accumulo Instance interface that communicates with
an Accumulo cluster via Accumulo's Apache Thrift proxy server. [Documentation](https://jhuapl.github.io/accumulo-proxy-instance/proxy_instance_user_manual) and
[code](https://github.com/JHUAPL/accumulo-proxy-instance) are available.

#### AccumuloGraph

ProxyInstance is an implementation of the TinkerPop Blueprints 2.6 API using
Apache Accumulo as the backend.
[Documentation](https://jhuapl.github.io/AccumuloGraph/) and
[code](https://github.com/JHUAPL/AccumuloGraph) are available.

## Github

[Github](https://github.com/search?q=accumulo&type=Repositories) also contains many projects that use/reference Accumulo
in some way, shape or form.
