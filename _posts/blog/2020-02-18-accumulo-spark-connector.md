---
title: "Microsoft MASC, an Apache Spark connector for Apache Accumulo"
---

## Overview
MASC provides an Apache Spark native connector for Apache Accumulo to integrate the rich Spark machine learning eco-system with the scalable and secure data storage capabilities of Accumulo. 

## Major Features
- Simplified Spark DataFrame read/write to Accumulo using DataSource v2 API
- Speedup of 2-5x over existing approaches for pulling key-value data into DataFrame format
- Scala and Python support without overhead for moving between languages
- Process streaming data from Accumulo without loading it all into Spark memory
- Push down filtering with a flexible expression language ([JUEL](http://juel.sourceforge.net/)): this allows the user to use logical operators and comparisons to reduce the amount of data returned from Accumulo 
- Column pruning based on selected fields transparently reduces the amount of data returned from Accumulo
- Server side inference: this allows the Accumulo nodes to be used to run ML model inference using MLeap to increase the scalability of AI solutions as well as keeping data in Accumulo.

## Use-Cases
There are many scenarios where use of this connector provides advantages, below we list a few common use-cases.

<b>Scenario 1</b>: A data analyst needs to execute model inference on large amount of data in Accumulo.
<b>Benefit</b>: Instead of transferring all the data to a large Spark cluster to score using a Spark model, the model can be exported and pushed down using the connector to run on the Accumulo cluster. This can reduce the need for a large Spark cluster as well as the amount of data transferred between systems, and can improve inference speeds (>2x speedups observed).

<b>Scenario 2</b>: A data scientist needs to train a Spark model on a large amount of data in Accumulo.
</b>Benefit</b>:Insted of pulling all the data into a large Spark cluster and restructuring the format to use Spark ML Lib tools, the connector allows for data to be streamed into Spark as a DataFrame reducing time to train and Spark cluster size / memory requirements.

<b>Scenario 3</b>: A data analyst needs to perform ad hoc analysis on large amounts of data stored in Accumulo.
<b>Benefit</b>: Instead of pulling all the data into a large Spark cluster, the connector allows for both rows and columns to be pruned using pushdown filtering with a flexible expression language.

## Architecture
<img src='/images/blog/202002_masc/architecture.png'>

## Usage

More detailed documentation on installation and use is available in the 
[Connector documentation](https://github.com/microsoft/masc/blob/master/connector/README.md)

### Dependencies
- Java 8
- Spark 2.4.3+
- Accumulo 2.0.0+

JARs available on Maven Central Repository:
- [![Maven Central](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-datasource/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-datasource) [Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-datasource)

- [![Maven Central](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-iterator/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-iterator) [Accumulo Iterator - Backend for Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-iterator)

### Example use
```python
# Read from Accumulo
df = (spark
      .read
      .format("com.microsoft.accumulo")
      .options(**options)  # define Accumulo properties
      .schema(schema))  # define schema for data retrieval

# Write to Accumulo
(df
 .write
 .format("com.microsoft.accumulo")
 .options(**options)
 .save())
```

See the [demo notebook](https://github.com/microsoft/masc/blob/master/connector/examples/AccumuloSparkConnector.ipynb) for more examples.


## Computational Performance of AI Scenario
<Define benchmarking experiments and results>

### Setup

1,000-node Accumulo Cluster (16,000 cores)
Version 2.0.0
256-node Spark cluster (4,096 cores)
Version 2.4.3

Machines: D16s_v3 (16 cores)


Use Twitter Sentiment 140 dataset (1.6 million tweets)
Text, sentiment, id, user, date

TODO: Include sample text?

In all experiments we use the same base dataset which is a collection of Twitter user tweets with labeled sentiment value. This dataset is known as the Sentiment140 dataset (Go, Bhayani, & Huang, 2009). The training data consist of 1.6M samples of tweets, where each tweet has columns indicating the sentiment label, user, timestamp, query term, and text. The text is limited to 140 characters and the overall uncompressed size of the training dataset is 227MB.


Prefix row ids with split keys
Upload prefixed data to Accumulo using MASC writer
Duplicate data using custom Accumulo iterator

Validate data partitioning
Accumulo monitor (port 9995)
Row count includes replicas (not always the same!)


### Results

Description

Training a sentiment model using SparkML
Regex Tokenizer
Hashing Transformer
Logistic Regression

Accumulo server-side inference using MLeap
Filtering results for 30% data transfer
Filtering results for 0% data transfer

Baseline
Plain count
Inference on Spark

TODO: insert graphs here


## License

This work is publicly available under the Apache License 2.0 on GitHub under [Microsoft's contributions for Apache Spark with Apache Accumulo](https://github.com/microsoft/masc). 


## Contributions 

Thanks to contributions from members on the Azure Government Customer Engineering and Azure Government teams.
[Markus Cozowicz](https://github.com/eisber),
[Scott Graham](https://github.com/gramhagen),
[Jun-Ki Min](https://github.com/loomlike),
[Chenhui Hu](https://github.com/chenhuims),
[Arvind Shyamsundar](https://github.com/arvindshmicrosoft),
[Marc Parisi](https://github.com/phrocker),
[Billie Rinaldi](https://github.com/billierinaldi),
[Anupam Sharma](https://github.com/AnupamMicrosoft),
[Tao Wu](https://github.com/wutaomsft)
and Pavandeep Kalra.