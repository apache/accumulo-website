# Microsoft MASC, an Apache Spark connector for Apache Accumulo

## Overview
<Define target audience / problem / use-cases>
MASC integrates Apache Spark and Apache Accumulo to leverage the rich Spark Machine Learning eco-system with scalable and secure data storage capabilities of Accumulo. This work is publicly available under the Apache License 2.0 on GitHub under [Microsoft's contributions for Spark with Apache Accumulo](https://github.com/microsoft/masc). 

## Architecture
<Show picture of architeure(s) colocated - remote>

## Dependencies
- Java 8
- Spark 2.4.3+
- Accumulo 2.0.0+

## Usage

PySpark based example is here: Accumulo-Spark Connector Demo Notebook.
[Connector documentation](https://github.com/microsoft/masc/blob/master/connector/README.md)

JARs available on Maven Central Repository:
- [![Maven Central](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-datasource/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-datasource) [Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-datasource)

- [![Maven Central](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-iterator/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.microsoft.masc/microsoft-accumulo-spark-iterator) [Accumulo Iterator - Backend for Spark DataSource](https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-iterator)


TODO: describe all options

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
 .format("org.apache.accumulo")
 .options(**options)
 .save())
```

## Major Features
- Simplified Spark DataFrame read/write to Accumulo using DataSource v2 API
- Speedup of 2-5x over existing approaches for pulling key-value data into DataFrame format
- Scala and Python support without overhead for moving between languages
- Process streaming data from Accumulo without loading it all into Spark memory
- Push down filtering with a flexible expression language ([JUEL](http://juel.sourceforge.net/)): this allows the user to use logical operators and comparisons to reduce the amount of data returned from Accumulo 
- Column pruning based on selected fields transparently reduces the amount of data returned from Accumulo
- Server side inference: this allows the Accumulo nodes to be used to run ML model inference using MLeap to increase the scalability of AI solutions as well as keeping data in Accumulo.

## Performance
<Define benchmarking experiments and results>

Feedback, questions, and contributions are welcome!

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