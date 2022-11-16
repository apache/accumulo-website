---
title: Troubleshooting Tools
category: troubleshooting
order: 3
---

The `accumulo` command can be used to run various tools and classes from the command line.

## RFileInfo

The `rfile-info` tool will examine an Accumulo storage file and print out basic metadata.

```
$ accumulo rfile-info /accumulo/tables/1/default_tablet/A000000n.rf
2013-07-16 08:17:14,778 [util.NativeCodeLoader] INFO : Loaded the native-hadoop library
Locality group         : <DEFAULT>
        Start block          : 0
        Num   blocks         : 1
        Index level 0        : 62 bytes  1 blocks
        First key            : 288be9ab4052fe9e span:34078a86a723e5d3:3da450f02108ced5 [] 1373373521623 false
        Last key             : start:13fc375709e id:615f5ee2dd822d7a [] 1373373821660 false
        Num entries          : 466
        Column families      : [waitForCommits, start, md major compactor 1, md major compactor 2, md major compactor 3,
                                 bringOnline, prep, md major compactor 4, md major compactor 5, md root major compactor 3,
                                 minorCompaction, wal, compactFiles, md root major compactor 4, md root major compactor 1,
                                 md root major compactor 2, compact, id, client:update, span, update, commit, write,
                                 majorCompaction]

Meta block     : BCFile.index
      Raw size             : 4 bytes
      Compressed size      : 12 bytes
      Compression type     : gz

Meta block     : RFile.index
      Raw size             : 780 bytes
      Compressed size      : 344 bytes
      Compression type     : gz
```

When trying to diagnose problems related to key size, the `rfile-info` tool can provide a histogram of the individual key sizes:

    $ accumulo rfile-info --histogram /accumulo/tables/1/default_tablet/A000000n.rf
    ...
    Up to size      count      %-age
             10 :        222  28.23%
            100 :        244  71.77%
           1000 :          0   0.00%
          10000 :          0   0.00%
         100000 :          0   0.00%
        1000000 :          0   0.00%
       10000000 :          0   0.00%
      100000000 :          0   0.00%
     1000000000 :          0   0.00%
    10000000000 :          0   0.00%

Likewise, `rfile-info` will dump the key-value pairs and show you the contents of the RFile:

    $ accumulo rfile-info --dump /accumulo/tables/1/default_tablet/A000000n.rf
    row columnFamily:columnQualifier [visibility] timestamp deleteFlag -> Value
    ...

### Encrypted Files

To examine an encrypted rfile the necessary encryption properties must be provided to the utility. To do this
the `accumulo.properties` file can be copied, the necessary encryption parameters added, and then the properties file can
be passed to the utility with the `-p` argument.

For example, if using `PerTableCryptoServiceFactory` and the `AESCryptoService`, you would need the following properties in
your accumulo.properties file:

```
general.custom.crypto.key.uri=<path-to-key>/data-encryption.key
instance.crypto.opts.factory=org.apache.accumulo.core.spi.crypto.PerTableCryptoServiceFactory
table.crypto.opts.service=org.apache.accumulo.core.spi.crypto.AESCryptoService
```

Example output:

```
$ accumulo rfile-info hdfs://localhost:8020/accumulo/tables/1/default_tablet/F0000001.rf -p <path-to-properties>/accumulo.properties
Reading file: hdfs://localhost:8020/accumulo/tables/1/default_tablet/F0000001.rf
Encrypted with Params: ...
...
RFile Version            : 8

Locality group           : <DEFAULT>
      Num   blocks           : 1
      Index level 0          : 37 bytes  1 blocks
      ...

Meta block     : BCFile.index
      Raw size             : 4 bytes
      ...

Meta block     : RFile.index
      Raw size             : 121 bytes
      ...
...
```

## GetManagerStats

The `GetManagerStats` tool can be used to retrieve Accumulo state and statistics:


    $ accumulo org.apache.accumulo.test.GetManagerStats | grep Load
     OS Load Average: 0.27

## FindOfflineTablets

If the Accumulo monitor shows an offline tablet, use `FindOfflineTablets` to find out which
tablet it is.

    $ accumulo org.apache.accumulo.server.util.FindOfflineTablets
    2<<@(null,null,localhost:9997) is UNASSIGNED  #walogs:2

Here's what the output means:

* `2<<` -
    This is the tablet from (-inf, pass:[+]inf) for the
    table with id 2.  The command `tables -l` in the shell will show table ids for
    tables.

* `@(null, null, localhost:9997)` -
    Location information.  The
    format is `@(assigned, hosted, last)`.  In this case, the
    tablet has not been assigned, is not hosted anywhere, and was once
    hosted on localhost.

* `#walogs:2` -
     The number of write-ahead logs that this tablet requires for recovery.

An unassigned tablet with write-ahead logs is probably waiting for
logs to be sorted for efficient recovery.

## CheckForMetadataProblems

The `CheckForMetadataProblems` tool can be used to make sure metadata
tables are up and consistent. It will verify the start/end of
every tablet matches, and the start and stop for the table is empty:

    $ accumulo org.apache.accumulo.server.util.CheckForMetadataProblems -u root --password
    Enter the connection password:
    Checking tables whose metadata is found in: accumulo.root (+r)
    ...All is well for table accumulo.metadata (!0)
    No problems found in accumulo.root (+r)

    Checking tables whose metadata is found in: accumulo.metadata (!0)
    ...All is well for table accumulo.replication (+rep)
    ...All is well for table trace (1)
    No problems found in accumulo.metadata (!0)

## RemoveEntriesForMissingFiles

If your Hadoop cluster has a lost a file due to a NameNode failure, you can remove
the file reference using `RemoveEntriesForMissingFiles`. It will check every file reference
and ensure that the file exists in HDFS.  Optionally, it will remove the reference:

    $ accumulo org.apache.accumulo.server.util.RemoveEntriesForMissingFiles -u root --password
    Enter the connection password:
    2013-07-16 13:10:57,293 [util.RemoveEntriesForMissingFiles] INFO : File /accumulo/tables/2/default_tablet/F0000005.rf
     is missing
    2013-07-16 13:10:57,296 [util.RemoveEntriesForMissingFiles] INFO : 1 files of 3 missing

## ChangeSecret (new in 2.1)

Changes the unique secret given to the instance that all servers must know. The utility can be run using the `accumulo admin` command.
Note that Accumulo must be shut down to run this utility.

```
$ accumulo admin changeSecret
Old secret:
New secret:
New instance id is 6e7f416b-c578-45df-8016-c9bc6b400e13
Be sure to put your new secret in accumulo.properties
```

## DeleteZooInstance (new in 2.1)

Deletes specific a specific instance name or id from zookeeper or cleans up all old instances. The utility can be run using the `accumulo admin` command.

To delete a specific instance use `-i` or `--instance` flags.

```
$ accumulo admin deleteZooInstance -i instance1
Deleted instance: instance1
```

If you try to delete the current instance a warning prompt will be displayed.

```
$ accumulo admin deleteZooInstance -i uno
Warning: This is the current instance, are you sure? (yes|no): no
Instance deletion of 'uno' cancelled.

$ accumulo admin deleteZooInstance -i uno
Warning: This is the current instance, are you sure? (yes|no): yes
Deleted instance: instance1
```

If you have entries in zookeeper for old instances that you no longer need, use the `-c` or `--clean` flags.
This command will not delete the instance pointed to by the local `accumulo.properties` file.

```
$ accumulo admin deleteZooInstance -c
Deleted instance: instance1
Deleted instance: instance2
```

## accumulo-util dump-zoo

To view the contents of ZooKeeper, run the following command:

```
$ accumulo-util dump-zoo
```

It can also be run using the `accumulo` command.

```
$ accumulo dump-zoo
```

If you would like to backup ZooKeeper, run the following command to write its contents as XML to file.

```
$ accumulo-util dump-zoo --xml --root /accumulo >dump.xml
```

## RestoreZookeeper

An XML dump file can be later used to restore ZooKeeper. The utility can be run using the `accumulo admin` command.

```
$ accumulo admin restoreZoo --overwrite < dump.xml
```

This command overwrites ZooKeeper so take care when using it. This is also why it cannot be called using `accumulo-util`.

## TabletServerLocks (new in 2.1)

List or delete Tablet Server locks. The utility can be run using the `accumulo admin` command.

```
$ accumulo admin locks
    localhost:9997 TSERV_CLIENT=localhost:9997

$ accumulo admin locks -delete localhost:9997

$ accumulo admin locks
    localhost:9997             <none>
```

## VerifyTabletAssignments (new in 2.1)

Verify all tablets are assigned to tablet servers. The utility can be run using the `accumulo admin` command.

```
$ accumulo admin verifyTabletAssigns
Checking table accumulo.metadata
Checking table accumulo.replication
Tablet +rep<< has no location
Checking table accumulo.root
Checking table t1
Checking table t2
Checking table t3

$ accumulo admin verifyTabletAssigns -v
Checking table accumulo.metadata
Tablet !0;~< is located at localhost:9997
Tablet !0<;~ is located at localhost:9997
Checking table accumulo.replication
Tablet +rep<< has no location
Checking table accumulo.root
Tablet +r<< is located at localhost:9997
Checking table t1
Tablet 1<< is located at localhost:9997
Checking table t2
Tablet 2<< is located at localhost:9997
Checking table t3
Tablet 3<< is located at localhost:9997
```

## zoo-info-viewer (new in 2.1)

View Accumulo information stored in ZooKeeper in a human-readable format.  The utility can be run without an Accumulo
instance. If an instance id or name is not provided on the command line, the instance will be read from
HDFS, otherwise only a running ZooKeeper instance is required to run the command.

To run the command:

    $ accumulo zoo-info-viewer [--instanceId id | --instanceName name] [mode-options] [--outfile filename]

    mode options:
    --print-instances
    --print-id-map
    --print-props [--system] [-ns | --namespaces list] [-t | --tables list]

## mode: print instances
The instance name(s) and instance id(s) are stored in ZooKeeper. To see the available name to id mapping run:

```
$ accumulo zoo-info-viewer  --print-instances

-----------------------------------------------
Report Time: 2022-05-31T21:07:19.673258Z
-----------------------------------------------
Instances (Instance Name, Instance ID)
test_a=1111465d-b7bb-42c2-919b-111111111111
test_b=2222465d-b7bb-42c2-919b-222222222222
uno=9cc9465d-b7bb-42c2-919b-ddf74b610c82

-----------------------------------------------
```

## mode: print id-map
If a shell is not available or convenient, the zoo-info-viewer can provide the same
information as the `namespaces -l` and `tables -l` commands. Note, the zoo-info-viewer output is
sorted by the id.

    $ accumulo zoo-info-viewer --print-id-map
    -----------------------------------------------
    Report Time: 2022-05-25T19:33:42.079969Z
    -----------------------------------------------
    ID Mapping (id => name) for instance: 8f006afd-8673-4a5a-b940-60405755197f
    Namespace ids:
    +accumulo =>                 accumulo
    +default  =>                       ""
    1         =>               ns_sample1

    Table ids:
    !0        =>        accumulo.metadata
    +r        =>            accumulo.root
    +rep      =>     accumulo.replication
    2         =>          ns_sample1.tbl1
    3         =>                     tbl2

    -----------------------------------------------

## mode: print property mappings

With Accumulo version 2.1, the storage of properties in ZooKeeper has changed and the properties are not directly
readable with the ZooKeeper zkCli utility.  The properties can be listed in an Accumulo shell with the `config` command.
However, if a shell is not available, this utility `zoo-info-viewer` can be used instead.

The `zoo-info-viewer` option `--print-props` with no other options will print all the configuration properties
for system, namespaces and tables.  The `print-props` can be filtered the with additional options, `--system` will print
the system configuration, `-ns` or `--namespaces` expects a list of the namespace names,
`-t` or `--tables` expects a list of table names included in the output.

```
$ accumulo zoo-info-viewer  --print-props

-----------------------------------------------
Report Time: 2022-05-31T21:18:11.562867Z
-----------------------------------------------
ZooKeeper properties for instance ID: 9cc9465d-b7bb-42c2-919b-ddf74b610c82

Name: System, Data Version:0, Data Timestamp: 2022-05-31T15:51:52.772265Z:
-- none --

Namespace:
Name: , Data Version:0, Data Timestamp: 2022-05-31T15:51:53.015613Z:
-- none --

Name: accumulo, Data Version:0, Data Timestamp: 2022-05-31T15:51:53.034172Z:
-- none --

Name: ns1, Data Version:0, Data Timestamp: 2022-05-31T21:17:22.927165Z:
-- none --

Tables:
Name: accumulo.metadata, Data Version:2, Data Timestamp: 2022-05-31T15:51:53.511811Z:
table.cache.block.enable=true
table.cache.index.enable=true
...

Name: accumulo.replication, Data Version:1, Data Timestamp: 2022-05-31T15:51:53.516346Z:
table.formatter=org.apache.accumulo.server.replication.StatusFormatter
table.group.repl=repl
...

Name: accumulo.root, Data Version:2, Data Timestamp: 2022-05-31T15:51:53.501174Z:
table.cache.block.enable=true
table.cache.index.enable=true
...

Name: ns1.tbl1, Data Version:1, Data Timestamp: 2022-05-31T21:17:41.111836Z:
table.constraint.1=org.apache.accumulo.core.data.constraints.DefaultKeySizeConstraint
table.iterator.majc.vers=20,org.apache.accumulo.core.iterators.user.VersioningIterator
...

Name: tbl3, Data Version:1, Data Timestamp: 2022-05-31T21:17:54.083044Z:
table.constraint.1=org.apache.accumulo.core.data.constraints.DefaultKeySizeConstraint
table.iterator.majc.vers=20,org.apache.accumulo.core.iterators.user.VersioningIterator
...
-----------------------------------------------
```
