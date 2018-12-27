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

## GetMasterStats

The `GetMasterStats` tool can be used to retrieve Accumulo state and statistics:


    $ accumulo org.apache.accumulo.test.GetMasterStats | grep Load
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
    All is well for table !0
    All is well for table 1

## RemoveEntriesForMissingFiles

If your Hadoop cluster has a lost a file due to a NameNode failure, you can remove the
the file reference using `RemoveEntriesForMissingFiles`. It will check every file reference
and ensure that the file exists in HDFS.  Optionally, it will remove the reference:

    $ accumulo org.apache.accumulo.server.util.RemoveEntriesForMissingFiles -u root --password
    Enter the connection password:
    2013-07-16 13:10:57,293 [util.RemoveEntriesForMissingFiles] INFO : File /accumulo/tables/2/default_tablet/F0000005.rf
     is missing
    2013-07-16 13:10:57,296 [util.RemoveEntriesForMissingFiles] INFO : 1 files of 3 missing

## CleanZookeeper

If you have entries in zookeeper for old instances that you no longer need, remove them using CleanZookeeper:

    $ accumulo org.apache.accumulo.server.util.CleanZookeeper

This command will not delete the instance pointed to by the local `accumulo.properties` file.

## accumulo-util dump-zoo

To view the contents of ZooKeeper, run the following command:

    $ accumulo-util dump-zoo

It can also be run using the `accumulo` command and full class name.

    $ accumulo org.apache.accumulo.server.util.DumpZookeeper

If you would like to backup ZooKeeper, run the following command to write its contents as XML to file.

    $ accumulo-util dump-zoo --xml --root /accumulo >dump.xml

# RestoreZookeeper

An XML dump file can be later used to restore ZooKeeper.

    $ accumulo org.apache.accumulo.server.util.RestoreZookeeper --overwrite < dump.xml

This command overwrites ZooKeeper so take care when using it. This is also why it cannot be called using `accumulo-util`.
