# Microsoft MASC, an Apache Spark connector for Apache Accumulo

## Overview
<Define target audience / problem / use-cases>
MASC integrates Apache Spark and Apache Accumulo to leverage the rich Spark Machine Learning eco-system with scalable and secure data storage capabilities of Accumulo. This work is publicly available under the Apache License 2.0 on GitHub at https://github.com/microsoft/masc. 

## Architecture
<Show picture of architeure(s) colocated - remote>

## Dependencies
- Java 8
- Spark 2.4.3+
- Accumulo 2.0.0+

## Usage

PySpark based example is here: Accumulo-Spark Connector Demo Notebook.
Connector documentation: https://github.com/microsoft/masc/blob/master/connector/README.md

JARs available on Maven Central Repository:
- https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-datasource
- https://mvnrepository.com/artifact/com.microsoft.masc/microsoft-accumulo-spark-iterator

## Major Features
- Simplified Spark DataFrame read/write to Accumulo using DataSource v2 API
- Speedup of 2-5x over existing approaches for pulling key-value data into DataFrame format
- Scala and Python support without overhead for moving between languages
- Process streaming data from Accumulo without loading it all into Spark memory
- Push down filtering with a flexible expression language (JUEL): this allows the user to use logical operators and comparisons to reduce the amount of data returned from Accumulo 
- Column pruning based on selected fields transparently reduces the amount of data returned from Accumulo
- Server side inference: this allows the Accumulo nodes to be used to run ML model inference using MLeap to increase the scalability of AI solutions as well as keeping data in Accumulo.

## Performance
<Define benchmarking experiments and results>

Feedback, questions, and contributions are welcome!

## Contributions 

Thanks to contributions from members on the Azure Government Customer Engineering and Azure Government teams.
Markus Cozowicz, Scott Graham, Jun-Ki Min, Chenhui Hu, Arvind Shyamsundar, Marc Parisi, Billie Rinaldi, Anupam Sharma, Tao Wu and Pavandeep Kalra.

