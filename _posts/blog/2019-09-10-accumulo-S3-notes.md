---
title: "Using S3 as a data store for Accumulo"
author: Keith Turner
---

Accumulo can store its files in S3, however S3 does not support the needs of
write ahead logs and the Accumulo metadata table. One way to solve this problem
is to store the metadata table and write ahead logs in HDFS and everything else
in S3.  This post shows how to do that using Accumulo 2.0 and Hadoop 3.2.0.
Running on S3 requires a new feature in Accumulo 2.0, that volume choosers are
aware of write ahead logs.

## Hadoop setup

At least the following settings should be added to Hadoop's `core-site.xml` file on each node in the cluster. 

```xml
<property>
  <name>fs.s3a.access.key</name>
  <value>KEY</value>
</property>
<property>
  <name>fs.s3a.secret.key</name>
  <value>SECRET</value>
</property>
<!-- without this setting Accumulo tservers would have problems when trying to open lots of files -->
<property>
  <name>fs.s3a.connection.maximum</name>
  <value>128</value>
</property>
```

See [S3A docs](https://hadoop.apache.org/docs/current/hadoop-aws/tools/hadoop-aws/index.html#S3A)
for more S3A settings.  To get hadoop command to work with s3 set `export
HADOOP_OPTIONAL_TOOLS="hadoop-aws"` in `hadoop-env.sh`.

When trying to use Accumulo with Hadoop's AWS jar [HADOOP-16080] was
encountered.  The following instructions build a relocated hadoop-aws jar as a
work around.  After building the jar copy it to all nodes in the cluster.

```bash
mkdir -p /tmp/haws-reloc
cd /tmp/haws-reloc
# get the Maven pom file that builds a relocated jar
wget https://gist.githubusercontent.com/keith-turner/f6dcbd33342732e42695d66509239983/raw/714cb801eb49084e0ceef5c6eb4027334fd51f87/pom.xml
mvn package -Dhadoop.version=<your hadoop version>
# the new jar will be in target
ls target/
```

## Accumulo setup

For each node in the cluster, modify `accumulo-env.sh` to add S3 jars to the
classpath.  Your versions may differ depending on your Hadoop version,
following versions were included with Hadoop 3.2.0.

```bash
CLASSPATH="${conf}:${lib}/*:${HADOOP_CONF_DIR}:${ZOOKEEPER_HOME}/*:${HADOOP_HOME}/share/hadoop/client/*"
CLASSPATH="${CLASSPATH}:/somedir/hadoop-aws-relocated.3.2.0.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar"
# The following are dependencies needed by by the previous jars and are subject to change
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/jaxb-api-2.2.11.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/commons-lang3-3.7jar"
export CLASSPATH
```

Set the following in `accumulo.properties` and then run `accumulo init`, but don't start Accumulo.


```ini
instance.volumes=hdfs://<name node>/accumulo
```

After running Accumulo init we need to configure storing write ahead logs in
HDFS.  Set the following in `accumulo.properties`.

```ini
instance.volumes=hdfs://<name node>/accumulo,s3a://<bucket>/accumulo
general.volume.chooser=org.apache.accumulo.server.fs.PreferredVolumeChooser
general.custom.volume.preferred.default=s3a://<bucket>/accumulo
general.custom.volume.preferred.logger=hdfs://<namenode>/accumulo

```

Run `accumulo init --add-volumes` to initialize the S3 volume.  Doing this
in two steps avoids putting any Accumulo metadata files in S3 during init.
Copy `accumulo.properties` to all nodes and start Accumulo.

Individual tables can be configured to store their files in HDFS by setting the
table property `table.custom.volume.preferred`.  This should be set for the
metadata table in case it splits using the following Accumulo shell command.

```
config -t accumulo.metadata -s table.custom.volume.preferred=hdfs://<namenode>/accumulo
```

## Accumulo example

The following Accumulo shell session shows an example of writing data to S3 and
reading it back.  It also shows scanning the metadata table to verify the data
is stored in S3.

```
root@muchos> createtable s3test
root@muchos s3test> insert r1 f1 q1 v1
root@muchos s3test> insert r1 f1 q2 v2
root@muchos s3test> flush -w
2019-09-10 19:39:04,695 [shell.Shell] INFO : Flush of table s3test  completed.
root@muchos s3test> scan 
r1 f1:q1 []    v1
r1 f1:q2 []    v2
root@muchos s3test> scan -t accumulo.metadata -c file
2< file:s3a://<bucket>/accumulo/tables/2/default_tablet/F000007b.rf []    234,2
```

These instructions were only tested a few times and may not result in a stable
system. I have [run] a 24hr test with Accumulo and S3.

## Is S3Guard needed?

I am not completely certain about this, but I don't think S3Guard is needed for
regular Accumulo tables.  There are two reasons I think this is so.  First each
Accumulo user tablet stores its list of files in the metadata table using
absolute URIs.  This allows a tablet to have files on multiple DFS instances.
Therefore Accumulo never does a DFS list operation to get a tablets files, it
always uses whats in the metadata table.  Second, Accumulo gives each file a
unique name using a counter stored in Zookeeper and file names are never
reused.

Things are sligthly different for Accumulo's metadata.  User tablets store
their file list in the metadata table.  Metadata tablets store their file list
in the root table.  The root table stores its file list in DFS.  Therefore it
would be dangerous to place the root tablet in S3 w/o using S3Guard.  That is
why these instructions place Accumulo metadata in HDFS. **Hopefully** this
configuration allows the system to be consistent w/o using S3Guard.

When Accumulo 2.1.0 is released with the changes made by {% ghi 1313 %} for issue
{% ghi 936 %}, it may be possible to store the metadata table in S3 w/o
S3Gaurd.  If this is the case then only the write ahead logs would need to be
stored in HDFS.

[HADOOP-16080]:https://issues.apache.org/jira/browse/HADOOP-16080
[run]: https://gist.github.com/keith-turner/149f35f218d10e13227461714012d7bf

