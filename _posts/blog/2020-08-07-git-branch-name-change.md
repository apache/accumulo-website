---
title: Microsoft MASC, an Apache Spark connector for Apache Accumulo
author: Markus Cozowicz, Scott Graham
---

# Overview
[MASC](https://github.com/microsoft/masc) provides an Apache Spark native connector for Apache Accumulo to integrate the rich Spark machine learning eco-system with the scalable and secure data storage capabilities of Accumulo. 

## Major Features
- Simplified Spark DataFrame read/write to Accumulo using DataSource v2 API
- Speedup of 2-5x over existing approaches for pulling key-value data into DataFrame format
- Scala and Python support without overhead for moving between languages
- Process streaming data from Accumulo without loading it all into Spark memory
- Push down filtering with a flexible expression language ([JUEL](http://juel.sourceforge.net/)): user can define logical operators and comparisons to reduce the amount of data returned from Accumulo 
- Column pruning based on selected fields transparently reduces the amount of data returned from Accumulo
- Server side inference: ML model inference can run on the Accumulo nodes using MLeap to increase the scalability of AI solutions as well as keeping data in Accumulo

## Use-cases
MASC is advantageous in many use-cases, below we list a few.

**Scenario 1**: A data analyst needs to execute model inference on large amount of data in Accumulo.<br>
**Benefit**: Instead of transferring all the data to a large Spark cluster to score using a Spark model, the connector exports and runs the model on the Accumulo cluster. This reduces the need for a large Spark cluster as well as the amount of data transferred between systems, and can improve inference speeds (>2x speedups observed).

**Scenario 2**: A data scientist needs to train a Spark model on a large amount of data in Accumulo.<br>
**Benefit**: Instead of pulling all the data into a large Spark cluster and restructuring the format to use Spark ML Lib tools, the connector streams data into Spark as a DataFrame reducing time to train and Spark cluster size / memory requirements.

**Scenario 3**: A data analyst needs to perform ad hoc analysis on large amounts of data stored in Accumulo.<br>
**Benefit**: Instead of pulling all the data into a large Spark cluster, the connector prunes rows and columns using pushdown filtering with a flexible expression language.

# Architecture
The Accumulo-Spark connector is composed of two components:

- Accumulo server-side iterator performs
  - column pruning
  - row-based filtering
  - [MLeap](https://github.com/combust/mleap) ML model inference and
  - row assembly using [Apache AVRO](https://avro.apache.org/)
- Spark DataSource V2 
  - determines the number of Spark tasks based on available Accumulo table splits
  - translates Spark filter conditions into a [JUEL](http://juel.sourceforge.net/) expression
  - configures the Accumulo iterator
  - deserializes the AVRO payload

![Architecture](/images/blog/202002_masc/architecture.svg "MASC Architecture Diagram")

# Usage
More detailed documentation on installation and use is available in the 
[Connector documentation](https://github.com/microsoft/masc/blob/master/connector/README.md)

## Dependencies
- Java 8
- Spark 2.4.3+
- Accumulo 2.0.0+

JARs available on Maven Central Repository:
- [![Maven Central](https://img.shields.io/maven-central/v/com.microsoft.masc/microsoft-accumulo-spark-datasource.svg?label=Maven%20Central) Spark DataSource](https://search.maven.org/search?q=g:%22com.microsoft.masc%22%20AND%20a:%22microsoft-accumulo-spark-datasource%22)

- [![Maven Central](https://img.shields.io/maven-central/v/com.microsoft.masc/microsoft-accumulo-spark-iterator.svg?label=Maven%20Central) Accumulo Iterator](https://search.maven.org/search?q=g:%22com.microsoft.masc%22%20AND%20a:%22microsoft-accumulo-spark-iterator%22) - Backend for Spark DataSource

## Example use
```python
from configparser import ConfigParser
from pyspark.sql import types as T

def get_properties(properties_file):
    """Read Accumulo client properties file"""
    config = ConfigParser()
    with open(properties_file) as stream:
        config.read_string("[top]\n" + stream.read())
    return dict(config['top'])

properties = get_properties('/opt/muchos/install/accumulo-2.0.0/conf/accumulo-client.properties')
properties['table'] = 'demo_table' # Define Accumulo table where data will be written
properties['rowkey'] = 'id'        # Identify column to use as the key for Accumulo rows

# define the schema
schema = T.StructType([
  T.StructField("sentiment", T.IntegerType(), True),
  T.StructField("date", T.StringType(), True),
  T.StructField("query_string", T.StringType(), True),
  T.StructField("user", T.StringType(), True),
  T.StructField("text", T.StringType(), True)
])

# Read from Accumulo
df = (spark
      .read
      .format("com.microsoft.accumulo")
      .options(**options)  # define Accumulo properties
      .schema(schema))     # define schema for data retrieval

# Write to Accumulo
properties['table'] = 'output_table'

(df
 .write
 .format("com.microsoft.accumulo")
 .options(**options)
 .save())
```

See the [demo notebook](https://github.com/microsoft/masc/blob/master/connector/examples/AccumuloSparkConnector.ipynb) for more examples.

# Computational Performance of AI Scenario
## Setup
The benchmark setup used a 1,000-node Accumulo 2.0.0 Cluster (16,000 cores) running and a 256-node Spark 2.4.3 cluster (4,096 cores). All nodes used [Azure D16s_v3](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general) (16 cores) virtual machines. [Fluo-muchos](https://github.com/apache/fluo-muchos) was used to handle Accumulo and Spark cluster deployments and configuration. 

In all experiments we use the same base dataset which is a collection of Twitter user tweets with labeled sentiment value. This dataset is known as the Sentiment140 dataset ([Go, Bhayani, & Huang, 2009](http://www-nlp.stanford.edu/courses/cs224n/2009/fp/3.pdf)). The training data consist of 1.6M samples of tweets, where each tweet has columns indicating the sentiment label, user, timestamp, query term, and text. The text is limited to 140 characters and the overall uncompressed size of the training dataset is 227MB.

| sentiment | id | date | query_string | user | text |
| --- | --- | --- | --- | --- | --- |
|0|1467810369|Mon Apr 06 22:19:...|    NO_QUERY|_TheSpecialOne_|@switchfoot http:...|
|0|1467810672|Mon Apr 06 22:19:...|    NO_QUERY|  scotthamilton|is upset that he ...|
|0|1467810917|Mon Apr 06 22:19:...|    NO_QUERY|       mattycus|@Kenichan I dived...|

To evaluate different table sizes and the impact of splitting the following procedure was used to generate the Accumulo tables:

- Prefix id with split keys (e.g. 0000, 0001, ..., 1024)
- Create Accumulo table and configure splits
- Upload prefixed data to Accumulo using Spark and the MASC writer 
- Duplicate data using custom Accumulo server-side iterator
- Validate data partitioning

A common machine learning scenario was evaluated using a sentiment model trained using [SparkML](https://spark.apache.org/docs/latest/ml-guide.html). 
To train the classification model, we generated feature vectors from the text of tweets (text column). We used a feature engineering pipeline (a.k.a. featurizer) that breaks the text into tokens, splitting on whitespaces and discarding any capitalization and non-alphabetical characters. The pipeline consisted of 

- Regex Tokenizer
- Hashing Transformer
- Logistic Regression

See the [benchmark notebook (Scala)](https://github.com/microsoft/masc/blob/master/connector/examples/AccumuloSparkConnectorBenchmark.ipynb) for more details.

## Results
The first set of experiments evaluated data transfer efficiency and ML model inference performance. The chart below shows

- Accumulo table split size (1GB, 8GB, 32GB, 64GB) 
- Total table size (1TB, 10TB, 100TB, 1PB)
- Operations
  - Count: plain count of the data
  - Inference: Accumulo server-side inference using MLeap
  - Transfer: Filtering results for 30% data transfer
- Time is reported in minutes

Remarks
- Time is log-scale
- Inference was run with and without data transfer to isolate server-side performance.
- The smaller each Accumulo table split is, the more splits we have and thus higher parallelization.

![Runtime](/images/blog/202002_masc/runtime.png "Runtime Performance"){:.blog-img-center}

The second set of experiments highlights the computational performance improvement of using the server-side inference approach compared to running inference on the Spark cluster.

![Mleap](/images/blog/202002_masc/sparkml_vs_mleap_accumulo.png "Spark ML vs MLeap Performance"){:.blog-img-center}

# Learnings
- Accumulo MLeap Server-side inference vs Spark ML results in a 2x improvement
- Multi-threading in Spark jobs can be used to fully utilize Accumulo servers
  - Useful when Spark cluster has less cores than Accumulo
  - e.g. 8 threads * 2,048 Spark executor = 16,384 Accumulo threads
- Unbalanced Accumulo table splits can introduce performance bottlenecks

# Useful links
- [Complete Jupyter demo notebook (PySpark)](https://github.com/microsoft/masc/blob/master/connector/examples/AccumuloSparkConnector.ipynb) for usage of the Accumulo-Spark connector
- [Complete Jupyter benchmark notebook (Scala)](https://github.com/microsoft/masc/blob/master/connector/examples/AccumuloSparkConnectorBenchmark.ipynb) for usage of the Accumulo-Spark connector
- GitHub Repository [Microsoft's contributions for Spark with Apache Accumulo](https://github.com/microsoft/masc)
- [MLeap](https://github.com/combust/mleap) - Scala/Java stand-alone model inference for SparkML-based models
- [SparkML](https://spark.apache.org/docs/latest/ml-guide.html) - Spark machine learning library
- MASC Maven artifacts
  - [Accumulo Iterator - Backend for Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-iterator)
  - [Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-datasource)

# License
This work is publicly available under the Apache License 2.0 on GitHub under [Microsoft's contributions for Apache Spark with Apache Accumulo](https://github.com/microsoft/masc). 

# Contributions 
Feedback, questions, and contributions are welcome!

Thanks to contributions from members on the Azure Global Customer Engineering and Azure Government teams.

- [Anupam Sharma](https://github.com/AnupamMicrosoft)
- [Arvind Shyamsundar](https://github.com/arvindshmicrosoft)
- [Billie Rinaldi](https://github.com/billierinaldi)
- [Chenhui Hu](https://github.com/chenhuims)
- [Jun-Ki Min](https://github.com/loomlike)
- [Marc Parisi](https://github.com/phrocker)
- [Markus Cozowicz](https://github.com/eisber)
- Pavandeep Kalra
- [Robert Alexander](https://github.com/roalexan)
- [Scott Graham](https://github.com/gramhagen)
- [Tao Wu](https://github.com/wutaomsft)

Special thanks to [Anca Sarb](https://github.com/ancasarb) for promptly assisting with [MLeap performance issues](https://github.com/combust/mleap/issues/633).
