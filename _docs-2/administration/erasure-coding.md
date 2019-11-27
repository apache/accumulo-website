---
title: Erasure Coding
category: administration
order: 9
---

With the release of version 3.0.0, Hadoop introduced the use of [Erasure Coding]
(EC) in HDFS.  By default HDFS achieves durability via block replication.
Usually the replication count is 3, resulting in a storage overhead of 200%.
Hadoop 3 introduced EC as a better way to achieve durability. EC behaves much 
like RAID 5 or 6...for *k* blocks of data, *m* blocks of parity data are generated,
from which the original data can be recovered in the event of disk or node 
failures (erasures, in EC parlance).  A typical EC scheme is Reed-Solomon 6-3,
where 6 data blocks produce 3 parity blocks, an overhead of only 50%.  In
addition to doubling the available disk space, RS-6-3 is also more fault
tolerant...a loss of 3 data blocks can be tolerated, whereas triple replication
can only sustain a loss of two.

To use EC with Accumulo, it is highly recommended that you first rebuild Hadoop 
with support for Intel's ISA-L library. Instructions for doing this can be found 
[here](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSErasureCoding.html#Enable_Intel_ISA-L)

### Important Warning
As noted 
[here](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSErasureCoding.html#Limitations),
the current EC implementation does not support `hflush()` and `hsync()`.  These 
functions are no-ops, which means that EC coded files are not guaranteed to
be written to disk after a sync or flush.  For this reason, **EC should never
be used for the Accumulo write-ahead logs.  Data loss may, and most likely will,
occur.** It is also recommended that tables in the `accumulo` namespace (`root` and
`metadata` for example) continue to use replication.

### EC and Threads
Due to the striped nature of an EC encoded file, an EC enabled HDFS client is threaded.
This becomes an issue when an Accumulo client or service is configured to use multiple
threads to read or write to HDFS, and becomes especially problematic when doing bulk
imports. By default, Accumulo will use eight times the number of cores on the client 
machine to scan the files to be imported and map them to tablet files. Each thread 
created to scan the input files will create on the order of *k* threads to perform
parallel I/O. RS-10-4 on a 16 core machine, for instance, will spawn over a thousand
threads to perform this operation. If sufficient memory is not available, this operation
will fail without providing a meaningful error message to the user.  This particular
problem can be ameliorated by setting the `bulk.threads` client property to `1C` (i.e.
one thread per core), down from the default of `8C`.  Similar care should be taken
when setting other thread limits.

### HDFS ec Command
Encoding policy in HDFS is set at the directory level, with children inheriting
policies from their parents if not explicitly set.  The encoding policy for a directory
can be manipulated via the `hdfs ec` command, documented
[here](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSErasureCoding.html#Administrative_commands).

The first step is to determine which policies are configured for your HDFS instance.
This is done via the `-listPolicies` command.  The following listing shows that there
are 5 configured policies, of which only 3 (RS-10-4-1024k, RS-6-3-1024k, and RS-6-3-64k)
are enabled for use.

```
$ hdfs ec -listPolicies
Erasure Coding Policies:
ErasureCodingPolicy=[Name=RS-10-4-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=10, numParityUnits=4]], CellSize=1048576, Id=5], State=ENABLED
ErasureCodingPolicy=[Name=RS-6-3-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=1], State=ENABLED
ErasureCodingPolicy=[Name=RS-6-3-64k, Schema=[ECSchema=[Codec=rs, numDataUnits=6, numParityUnits=3, options=]], CellSize=65536, Id=65], State=ENABLED
ErasureCodingPolicy=[Name=RS-LEGACY-6-3-1024k, Schema=[ECSchema=[Codec=rs-legacy, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=3], State=DISABLED
ErasureCodingPolicy=[Name=XOR-2-1-1024k, Schema=[ECSchema=[Codec=xor, numDataUnits=2, numParityUnits=1]], CellSize=1048576, Id=4], State=DISABLED
```

To set the encoding policy for a directory, use the `-setPolicy` command.

```
$ hadoop fs -mkdir foo
$ hdfs ec -setPolicy -policy RS-6-3-64k -path foo
Set RS-6-3-64k erasure coding policy on foo
```

To get the encoding policy for a directory, use the `-getPolicy` command.

```
$ hdfs ec -getPolicy -path foo
RS-6-3-64k
```

New directories created under `foo` will inherit the EC policy.

```
$ hadoop fs -mkdir foo/bar
$ hdfs ec -getPolicy -path foo/bar
RS-6-3-64k
```

And changing the policy for a parent will also change its children.  The `-setPolicy`
command here issues a warning that existing files will not be converted.  To 
switch the policy for an existing file, you must create a new file (through
a copy, for instance).  For Accumulo, if you change the encoding policy for
a table's directories, you would then have to perform a major compaction on
the table to convert the table's RFiles to the desired encoding.

```
$ hdfs ec -setPolicy -policy RS-6-3-1024k -path foo
Set RS-6-3-1024k erasure coding policy on foo
Warning: setting erasure coding policy on a non-empty directory will not automatically convert existing files to RS-6-3-1024k erasure coding policy
$ hdfs ec -getPolicy -path foo
RS-6-3-1024k
$ hdfs ec -getPolicy -path foo/bar
RS-6-3-1024k
```

### Configuring EC for a New Instance
If you wish to create a new instance with a single encoding policy for all tables,
you simply need to change the encoding policy on the `tables` directory after
running `accumulo init` (see 
[Quick Start]({% durl getting-started/quickstart#initialization %}) guide).  To
keep the tables in the `accumulo` namespace using replication, you
would then need to manually change them back to using replication.  Assuming
Accumulo is configured to use `/accumulo` as its root, you would do the following:

```
$ hdfs ec -setPolicy -policy RS-6-3-64k -path /accumulo/tables
Set RS-6-3-64k erasure coding policy on /accumulo/tables
$ hdfs ec -setPolicy -replicate -path /accumulo/tables/\!0
Set replication erasure coding policy on /accumulo/tables/!0
$ hdfs ec -setPolicy -replicate -path /accumulo/tables/+r
Set replication erasure coding policy on /accumulo/tables/+r
$ hdfs ec -setPolicy -replicate -path /accumulo/tables/+rep
Set replication erasure coding policy on /accumulo/tables/+rep
```

Check that the policies are set correctly:

```
$ hdfs ec -getPolicy -path /accumulo/tables
RS-6-3-64k
$ hdfs ec -getPolicy -path /accumulo/tables/\!0
The erasure coding policy of /accumulo/tables/!0 is unspecified
```

Any directories subsequently created under `/accumulo/tables` will
be erasure coded.

### Configuring EC for an Existing Instance
For an existing installation, the instructions are the same, but with the
caveat that changing the encoding policy for an existing directory will not
change the files within the directory. Converting existing tables to EC
requires a major compaction to complete the process.  For instance, to
convert `test.table1` to RS-6-3-64k, you would first find the table ID
via the accumulo shell, use `hdfs ec` to change the encoding for the
directory `/accumulo/tables/<tableID>`, and then compact the table.

```
$ accumulo shell
user@instance> tables -l
accumulo.metadata    =>        !0
accumulo.replication =>      +rep
accumulo.root        =>        +r
test.table1          =>         3
test.table2          =>         4
test.table3          =>         5
trace                =>         1
user@instance> quit
$ hdfs ec -setPolicy -policy RS-6-3-64k -path /accumulo/tables/3
Set RS-6-3-64k erasure coding policy on /accumulo/tables/3
$ accumulo shell
user@instance> compact -t test.table1
```

### Defining Custom EC Policies
Hadoop by default will enable only a single EC policy, which is
determined by the value of the `dfs.namenode.ec.system.default.policy` 
configuration setting.  To enable an existing policy, use the `hdfs ec -enablePolicy`
command.  To define custom policies, you must first edit the 
`user_ec_policies.xml` file found in the Hadoop configuration directory,
and then run the `hdfs ec -addPolicies` command.  For example, to add 
RS-6-3-64k as a policy, you first edit `user_ec_policies.xml` and add
the following:

```xml
<configuration>
<layoutversion>1</layoutversion>
<schemas>
  <!-- schema id is only used to reference internally in this document -->
  <schema id="RSk6m3">
    <codec>rs</codec>
    <k>6</k>
    <m>3</m>
    <options> </options>
  </schema>
</schemas>
<policies>
  <policy>
    <schema>RSk6m3</schema>
    <cellsize>65536</cellsize>
  </policy>
</policies>
</configuration>
```
Here the schema "RSk6m3" defines a Reed-Solomon encoding with *k*=6 
data blocks and *m*=3 parity blocks.  This schema is then used to define
a policy that uses RS-6-3 encoding with a stripe size of 64k.  To add
this policy:

```
$ hdfs ec -addPolicies -policyFile /hadoop/etc/hadoop/user_ec_policies.xml
2019-11-19 15:35:23,703 INFO util.ECPolicyLoader: Loading EC policy file /hadoop/etc/hadoop/user_ec_policies.xml
Add ErasureCodingPolicy RS-6-3-64k succeed.
```

To enable the policy:

```
$ hdfs ec -enablePolicy -policy RS-6-3-64k
Erasure coding policy RS-6-3-64k is enabled
```

[Erasure Coding]: https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSErasureCoding.html