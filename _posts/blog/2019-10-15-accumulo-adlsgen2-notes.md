---
title: "Using Azure Data Lake Gen2 storage as a data store for Accumulo"
author: Karthick Narendran
---

Accumulo can store its files in [Azure Data Lake Storage Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction)
using the [ABFS (Azure Blob File System)](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-abfs-driver) driver.
Similar to [S3 blog](https://accumulo.apache.org/blog/2019/09/10/accumulo-S3-notes.html), 
the write ahead logs & Accumulo metadata can be stored in HDFS and everything else on Gen2 storage
using the volume chooser feature introduced in Accumulo 2.0. The configurations referred on this blog
are specific to Accumulo 2.0 and Hadoop 3.2.0.

## Hadoop setup

For ABFS client to talk to Gen2 storage, it requires one of the Authentication mechanism listed [here](https://hadoop.apache.org/docs/current/hadoop-azure/abfs.html#Authentication)
This post covers [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
formerly known as Managed Service Identity or MSI. This feature provides Azure services with an 
automatically managed identity in [Azure AD](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-whatis)
and it avoids the need for credentials or other sensitive information from being stored in code 
or configs/JCEKS. Plus, it comes free with Azure AD.  

At least the following should be added to Hadoop's `core-site.xml` on each node. 

```xml
<property>
  <name>fs.azure.account.auth.type</name>
  <value>OAuth</value>
</property>
<property>
  <name>fs.azure.account.oauth.provider.type</name>
  <value>org.apache.hadoop.fs.azurebfs.oauth2.MsiTokenProvider</value>
</property>
<property>
  <name>fs.azure.account.oauth2.msi.tenant</name>
  <value>TenantID</value>
</property>
<property>
  <name>fs.azure.account.oauth2.client.id</name>
  <value>ClientID</value>
</property>
```
 
See [ABFS doc](https://hadoop.apache.org/docs/current/hadoop-azure/abfs.html)
for more information on Hadoop Azure support.

To get hadoop command to work with ADLS Gen2 set the 
following entries in `hadoop-env.sh`. As Gen2 storage is TLS enabled by default, 
it is important we use the native OpenSSL implementation of TLS.

```bash
export HADOOP_OPTIONAL_TOOLS="hadoop-azure"
export HADOOP_OPTS="-Dorg.wildfly.openssl.path=<path/to/OpenSSL/libraries> ${HADOOP_OPTS}"
```

To verify the location of the OpenSSL libraries, run `whereis libssl` command 
on the host

## Accumulo setup

For each node in the cluster, modify `accumulo-env.sh` to add Azure storage jars to the
classpath.  Your versions may differ depending on your Hadoop version,
following versions were included with Hadoop 3.2.0.

```bash
CLASSPATH="${conf}:${lib}/*:${HADOOP_CONF_DIR}:${ZOOKEEPER_HOME}/*:${HADOOP_HOME}/share/hadoop/client/*"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/azure-data-lake-store-sdk-2.2.9.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/azure-keyvault-core-1.0.0.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-azure-3.2.0.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/wildfly-openssl-1.0.4.Final.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/jaxb-api-2.2.11.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/commons-lang3-3.7.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/httpclient-4.5.2.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/jackson-core-asl-1.9.13.jar"
CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/jackson-mapper-asl-1.9.13.jar"
export CLASSPATH
```

Include `-Dorg.wildfly.openssl.path` to `JAVA_OPTS` in `accumulo-env.sh` as shown below. This
java property is an optional performance enhancement for TLS.

```bash
JAVA_OPTS=("${ACCUMULO_JAVA_OPTS[@]}"
  '-XX:+UseConcMarkSweepGC'
  '-XX:CMSInitiatingOccupancyFraction=75'
  '-XX:+CMSClassUnloadingEnabled'
  '-XX:OnOutOfMemoryError=kill -9 %p'
  '-XX:-OmitStackTraceInFastThrow'
  '-Djava.net.preferIPv4Stack=true'
  '-Dorg.wildfly.openssl.path=/usr/lib64'
  "-Daccumulo.native.lib.path=${lib}/native")
```

Set the following in `accumulo.properties` and then run `accumulo init`, but don't start Accumulo.

```ini
instance.volumes=hdfs://<name node>/accumulo
```

After running Accumulo init we need to configure storing write ahead logs in
HDFS.  Set the following in `accumulo.properties`.

```ini
instance.volumes=hdfs://<namenode>/accumulo,abfss://<file_system>@<storage_account_name>.dfs.core.windows.net/accumulo
general.volume.chooser=org.apache.accumulo.server.fs.PreferredVolumeChooser
general.custom.volume.preferred.default=abfss://<file_system>@<storage_account_name>.dfs.core.windows.net/accumulo
general.custom.volume.preferred.logger=hdfs://<namenode>/accumulo
```

Run `accumulo init --add-volumes` to initialize the Azure DLS Gen2 volume.  Doing this
in two steps avoids putting any Accumulo metadata files in Gen2  during init.
Copy `accumulo.properties` to all nodes and start Accumulo.

Individual tables can be configured to store their files in HDFS by setting the
table property `table.custom.volume.preferred`.  This should be set for the
metadata table in case it splits using the following Accumulo shell command.

```
config -t accumulo.metadata -s table.custom.volume.preferred=hdfs://<namenode>/accumulo
```

## Accumulo example

The following Accumulo shell session shows an example of writing data to Gen2 and
reading it back.  It also shows scanning the metadata table to verify the data
is stored in Gen2.

```
root@muchos> createtable gen2test
root@muchos gen2test> insert r1 f1 q1 v1
root@muchos gen2test> insert r1 f1 q2 v2
root@muchos gen2test> flush -w
2019-10-16 08:01:00,564 [shell.Shell] INFO : Flush of table gen2test  completed.
root@muchos gen2test> scan
r1 f1:q1 []    v1
r1 f1:q2 []    v2
root@muchos gen2test> scan -t accumulo.metadata -c file
4< file:abfss://<file_system>@<storage_account_name>.dfs.core.windows.net/accumulo/tables/4/default_tablet/F00000gj.rf []    234,2
```

These instructions will help to configure Accumulo to use Azure's Data Lake Gen2 Storage along with HDFS. With this setup, 
we are able to successfully run the continuos ingest test. Going forward, we'll experiment more on this space 
with ADLS Gen2 and add/update blog as we come along.


