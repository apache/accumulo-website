---
title: Microsoft MASC, an Apache Spark connector for Apache Accumulo
---

# Overview
MASC provides an Apache Spark native connector for Apache Accumulo to integrate the rich Spark machine learning eco-system with the scalable and secure data storage capabilities of Accumulo. 

## Major Features
- Simplified Spark DataFrame read/write to Accumulo using DataSource v2 API
- Speedup of 2-5x over existing approaches for pulling key-value data into DataFrame format
- Scala and Python support without overhead for moving between languages
- Process streaming data from Accumulo without loading it all into Spark memory
- Push down filtering with a flexible expression language ([JUEL](http://juel.sourceforge.net/)): this allows the user to use logical operators and comparisons to reduce the amount of data returned from Accumulo 
- Column pruning based on selected fields transparently reduces the amount of data returned from Accumulo
- Server side inference: this allows the Accumulo nodes to be used to run ML model inference using MLeap to increase the scalability of AI solutions as well as keeping data in Accumulo.

## Use-cases
There are many scenarios where use of this connector provides advantages, below we list a few common use-cases.

**Scenario 1**: A data analyst needs to execute model inference on large amount of data in Accumulo.  
**Benefit**: Instead of transferring all the data to a large Spark cluster to score using a Spark model, the model can be exported and pushed down using the connector to run on the Accumulo cluster. This can reduce the need for a large Spark cluster as well as the amount of data transferred between systems, and can improve inference speeds (>2x speedups observed).

**Scenario 2**: A data scientist needs to train a Spark model on a large amount of data in Accumulo.  
**Benefit**:Insted of pulling all the data into a large Spark cluster and restructuring the format to use Spark ML Lib tools, the connector allows for data to be streamed into Spark as a DataFrame reducing time to train and Spark cluster size / memory requirements.

# Architecture
The Accumulo-Spark connector is composed of two components:

- Accumulo server-side iterator performs
  - column pruning
  - row-based filtering
  - [MLeap](https://github.com/combust/mleap) ML model inference and
  - row assembly using [Apache AVRO](https://avro.apache.org/)
- Spark DataSource V2 
  - determines the number of Spark tasks based on available Accumulo table splits
  - translates Spark filter conditions into a [JUEL](http://juel.sourceforge.net/)  expression
  - configures the Accumulo iterator
  - deserializes the AVRO payload

<img class="blog-img-center" src="/images/blog/202002_masc/architecture.svg">

# Usage
More detailed documentation on installation and use is available in the 
[Connector documentation](https://github.com/microsoft/masc/blob/master/connector/README.md)

## Dependencies
- Java 8
- Spark 2.4.3+
- Accumulo 2.0.0+

JARs available on Maven Central Repository:
- [![Maven Central](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-datasource/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-datasource) [Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-datasource)

- [![Maven Central](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-iterator/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-iterator) [Accumulo Iterator - Backend for Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-iterator)

## Example use
```python
from configparser import ConfigParser

def get_properties(properties_file):
    """Read Accumulo client properties file"""
    config = ConfigParser()
    with open(properties_file) as stream:
        config.read_string("[top]\n" + stream.read())
    return dict(config['top'])

properties = get_properties('/opt/muchos/install/accumulo-2.0.0/conf/accumulo-client.properties')
properties['table'] = 'demo_table' # Define Accumulo table where data will be written
properties['rowkey'] = 'id'        # Identify column to use as the key for Accumulo rows

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
 .format("org.apache.accumulo")
 .options(**options)
 .save())
```

See the [demo notebook](https://github.com/microsoft/masc/blob/master/connector/examples/AccumuloSparkConnector.ipynb) for more examples.

# Computational Performance of AI Scenario
TODO: Define benchmarking experiments and results

## Setup
The benchmark setup used a 1,000-node Accumulo 2.0.0 Cluster (16,000 cores) running and a 256-node Spark 2.4.3 cluster (4,096 cores). All nodes used [Azure D16s_v3](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general) (16 cores) virtual machines.

In all experiments we use the same base dataset which is a collection of Twitter user tweets with labeled sentiment value. This dataset is known as the Sentiment140 dataset ([Go, Bhayani, & Huang, 2009](http://www-nlp.stanford.edu/courses/cs224n/2009/fp/3.pdf)). The training data consist of 1.6M samples of tweets, where each tweet has columns indicating the sentiment label, user, timestamp, query term, and text. The text is limited to 140 characters and the overall uncompressed size of the training dataset is 227MB.

| sentiment | id | date | query_string | user | text |
| --- | --- | --- | --- | --- | --- |
|0|1467810369|Mon Apr 06 22:19:...|    NO_QUERY|_TheSpecialOne_|@switchfoot http:...|
|0|1467810672|Mon Apr 06 22:19:...|    NO_QUERY|  scotthamilton|is upset that he ...|
|0|1467810917|Mon Apr 06 22:19:...|    NO_QUERY|       mattycus|@Kenichan I dived...|

To evaluate different table sizes and the impact of splitting the following procedure was used to generate the Accumulo tables:

- Prefix id with split keys (e.g. 0000, 0001, ..., 1024)
- Create Accumulo table and configure splits
- Upload prefixed data to Accumulo using Spark MASC writer
- Duplicate data using custom Accumulo server-side iterator
- Validate data partitioning

Machine learning scenarios were evaluated using a sentiment model trained using [SparkML](https://spark.apache.org/docs/latest/ml-guide.html). 
To train the classification model, we need to generate feature vectors from the text of tweets (text column). We start with a feature engineering pipeline (a.k.a. featurizer) that breaks the text into tokens, splitting on whitespaces and discarding any capitalization and non-alphabetical characters. The pipeline consists of 

- Regex Tokenizer
- Hashing Transformer
- Logistic Regression


## Results
The first set of experiment evaluated data transfer efficiency and ML model inference performance. The chart below shows

- Accumulo table split size (1GB, 8GB, 32GB, 64GB)
- Total table size (1TB, 10TB, 100TB, 1PB)
- Operations
  - Count: plain count of the data
  - Inference: Accumulo server-side inference using MLeap and filtering results for 0% data transfer
  - Inference + Xfer: Accumulo server-side inference using MLeap and filtering results for 30% data transfer
- Time is reported in minutes (note the log-scale)

<img class="blog-img-center" src="/images/blog/202002_masc/runtime.png">

The second set of experiments highlights the computational performance improvement of using the server-side inference approach compared to run inference on the Spark cluster.

<img class="blog-img-center" src="/images/blog/202002_masc/sparkml_vs_mleap_accumulo.png"> 

## Learnings
- Accumulo MLeap Server-side inference vs Spark ML results in a 2x improvement
- Using multi-threading to address multiple Accumulo servers
- Useful if less Spark cores available or heavy on Accumulo
  - e.g. 8 threads * 2,048 Spark executor = 16,384 Accumulo threads
- Unbalanced Accumulo splits can skew results

# Useful links
- [Complete Jupyter demo notebook](https://github.com/microsoft/masc/blob/master/connector/examples/AccumuloSparkConnector.ipynb) for usage of the Accumulo-Spark connector
- [GitHub Repository Microsoft's contributions for Spark with Apache Accumulo](https://github.com/microsoft/masc)
- [MLeap](https://github.com/combust/mleap)
- [SparkML](https://spark.apache.org/docs/latest/ml-guide.html)
- Maven artifacts
  - [Accumulo Iterator - Backend for Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-iterator)
  - [Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-datasource)

## License
This work is publicly available under the Apache License 2.0 on GitHub under [Microsoft's contributions for Apache Spark with Apache Accumulo](https://github.com/microsoft/masc). 

# Contributions 
Feedback, questions, and contributions are welcome!

Thanks to contributions from members on the Azure Government Customer Engineering and Azure Government teams.
[Markus Cozowicz](https://github.com/eisber),
[Scott Graham](https://github.com/gramhagen),
[Jun-Ki Min](https://github.com/loomlike),
[Chenhui Hu](https://github.com/chenhuims),
[Arvind Shyamsundar](https://github.com/arvindshmicrosoft),
[Marc Parisi](https://github.com/phrocker),
[Robert Alexander](https://github.com/roalexan),
[Billie Rinaldi](https://github.com/billierinaldi),
[Anupam Sharma](https://github.com/AnupamMicrosoft),
[Tao Wu](https://github.com/wutaomsft)
and Pavandeep Kalra.

Special thanks to [Anca Sarb](https://github.com/ancasarb) for promptly assisting with [MLeap performance issues](https://github.com/combust/mleap/issues/633).