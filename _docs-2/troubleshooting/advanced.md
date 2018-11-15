---
title: Advanced Troubleshooting
category: troubleshooting
order: 2
---

## Tablet server locks

**My tablet server lost its lock.  Why?**

The primary reason a tablet server loses its lock is that it has been pushed into swap.

A large java program (like the tablet server) may have a large portion
of its memory image unused.  The operation system will favor pushing
this allocated, but unused memory into swap so that the memory can be
re-used as a disk buffer.  When the java virtual machine decides to
access this memory, the OS will begin flushing disk buffers to return that
memory to the VM.  This can cause the entire process to block long
enough for the zookeeper lock to be lost.

Configure your system to reduce the kernel parameter _swappiness_ from the default (60) to zero.

**My tablet server lost its lock, and I have already set swappiness to zero.  Why?**

Be careful not to over-subscribe memory.  This can be easy to do if
your accumulo processes run on the same nodes as hadoop's map-reduce
framework.  Remember to add up:

* size of the JVM for the tablet server
* size of the in-memory map, if using the native map implementation
* size of the JVM for the data node
* size of the JVM for the task tracker
* size of the JVM times the maximum number of mappers and reducers
* size of the kernel and any support processes

If a 16G node can run 2 mappers and 2 reducers, and each can be 2G,
then there is only 8G for the data node, tserver, task tracker and OS.

Reduce the memory footprint of each component until it fits comfortably.

**My tablet server lost its lock, swappiness is zero, and my node has lots of unused memory!**

The JVM memory garbage collector may fall behind and cause a
"stop-the-world" garbage collection. On a large memory virtual
machine, this collection can take a long time.  This happens more
frequently when the JVM is getting low on free memory.  Check the logs
of the tablet server.  You will see lines like this:

    2013-06-20 13:43:20,607 [tabletserver.TabletServer] DEBUG: gc ParNew=0.00(+0.00) secs
        ConcurrentMarkSweep=0.00(+0.00) secs freemem=1,868,325,952(+1,868,325,952) totalmem=2,040,135,680

When `freemem` becomes small relative to the amount of memory
needed, the JVM will spend more time finding free memory than
performing work.  This can cause long delays in sending keep-alive
messages to zookeeper.

Ensure the tablet server JVM is not running low on memory.

**I'm seeing errors in tablet server logs that include the words "MutationsRejectedException" and "# constraint violations: 1". Moments after that the server died.**

The error you are seeing is part of a failing tablet server scenario.
This is a bit complicated, so name two of your tablet servers A and B.

Tablet server A is hosting a tablet, let's call it a-tablet.

Tablet server B is hosting a metadata tablet, let's call it m-tablet.

m-tablet records the information about a-tablet, for example, the names of the files it is using to store data.

When A ingests some data, it eventually flushes the updates from memory to a file.

Tablet server A then writes this new information to m-tablet, on Tablet server B.

Here's a likely failure scenario:

Tablet server A does not have enough memory for all the processes running on it.
The operating system sees a large chunk of the tablet server being unused, and swaps it out to disk to make room for other processes.
Tablet server A does a java memory garbage collection, which causes it to start using all the memory allocated to it.
As the server starts pulling data from swap, it runs very slowly.
It fails to send the keep-alive messages to zookeeper in a timely fashion, and it looses its zookeeper session.

But, it's running so slowly, that it takes a moment to realize it should no longer be hosting tablets.

The thread that is flushing a-tablet memory attempts to update m-tablet with the new file information.

Fortunately there's a constraint on m-tablet.
Mutations to the metadata table must contain a valid zookeeper session.
This prevents tablet server A from making updates to m-tablet when it no long has the right to host the tablet.

The "MutationsRejectedException" error is from tablet server A making an update to tablet server B's m-tablet.
It's getting a constraint violation: tablet server A has lost its zookeeper session, and will fail momentarily.

Ensure that memory is not over-allocated.  Monitor swap usage, or turn swap off.

**My accumulo client is getting a MutationsRejectedException. The monitor is displaying "No Such SessionID" errors.**

When your client starts sending mutations to accumulo, it creates a session. Once the session is created,
mutations are streamed to accumulo, without acknowledgement, against this session.  Once the client is done,
it will close the session, and get an acknowledgement.

If the client fails to communicate with accumulo, it will release the session, assuming that the client has died.
If the client then attempts to send more mutations against the session, you will see "No Such SessionID" errors on
the server, and MutationRejectedExceptions in the client.

The client library should be either actively using the connection to the tablet servers,
or closing the connection and sessions. If the session times out, something is causing your client
to pause.

The most frequent source of these pauses are java garbage collection pauses
due to the JVM running out of memory, or being swapped out to disk.

Ensure your client has adequate memory and is not being swapped out to disk.

## HDFS Failures

**I had disastrous HDFS failure.  After bringing everything back up, several tablets refuse to go online.**

Data written to tablets is written into memory before being written into indexed files.  In case the server
is lost before the data is saved into a an indexed file, all data stored in memory is first written into a
write-ahead log (WAL).  When a tablet is re-assigned to a new tablet server, the write-ahead logs are read to
recover any mutations that were in memory when the tablet was last hosted.

If a write-ahead log cannot be read, then the tablet is not re-assigned.  All it takes is for one of
the blocks in the write-ahead log to be missing.  This is unlikely unless multiple data nodes in HDFS have been
lost.

Get the WAL files online and healthy.  Restore any data nodes that may be down.

**How do find out which tablets are offline?**

Use `accumulo admin checkTablets`

    $ accumulo admin checkTablets

**I lost three data nodes, and I'm missing blocks in a WAL.  I don't care about data loss, how
can I get those tablets online?**

See the [system metadata table page][metadata] which shows a typical metadata table listing.
The entries with a column family of `log` are references to the WAL for that tablet.
If you know what WAL is bad, you can find all the references with a grep in the shell:

    shell> grep 0cb7ce52-ac46-4bf7-ae1d-acdcfaa97995
    3< log:127.0.0.1+9997/0cb7ce52-ac46-4bf7-ae1d-acdcfaa97995 []    127.0.0.1+9997/0cb7ce52-ac46-4bf7-ae1d-acdcfaa97995|6

You can remove the WAL references in the metadata table.

    shell> grant -u root Table.WRITE -t accumulo.metadata
    shell> delete 3< log 127.0.0.1+9997/0cb7ce52-ac46-4bf7-ae1d-acdcfaa97995

Note: the colon (`:`) is omitted when specifying the _row cf cq_ for the delete command.

The master will automatically discover the tablet no longer has a bad WAL reference and will
assign the tablet.  You will need to remove the reference from all the tablets to get them
online.

**The metadata (or root) table has references to a corrupt WAL.**

This is a much more serious state, since losing updates to the metadata table will result
in references to old files which may not exist, or lost references to new files, resulting
in tablets that cannot be read, or large amounts of data loss.

The best hope is to restore the WAL by fixing HDFS data nodes and bringing the data back online.
If this is not possible, the best approach is to re-create the instance and bulk import all files from
the old instance into a new tables.

A complete set of instructions for doing this is outside the scope of this guide,
but the basic approach is:

* Use `tables -l` in the shell to discover the table name to table id mapping
* Stop all accumulo processes on all nodes
* Move the accumulo directory in HDFS out of the way:
       $ hadoop fs -mv /accumulo /corrupt
* Re-initialize accumulo
* Recreate tables, users and permissions
* Import the directories under `/corrupt/tables/<id>` into the new instance

**One or more HDFS Files under /accumulo/tables are corrupt**

Accumulo maintains multiple references into the tablet files in the metadata
tables and within the tablet server hosting the file, this makes it difficult to
reliably just remove those references.

The directory structure in HDFS for tables will follow the general structure:

    /accumulo
    /accumulo/tables/
    /accumulo/tables/!0
    /accumulo/tables/!0/default_tablet/A000001.rf
    /accumulo/tables/!0/t-00001/A000002.rf
    /accumulo/tables/1
    /accumulo/tables/1/default_tablet/A000003.rf
    /accumulo/tables/1/t-00001/A000004.rf
    /accumulo/tables/1/t-00001/A000005.rf
    /accumulo/tables/2/default_tablet/A000006.rf
    /accumulo/tables/2/t-00001/A000007.rf

If files under `/accumulo/tables` are corrupt, the best course of action is to
recover those files in hdsf see the section on HDFS. Once these recovery efforts
have been exhausted, the next step depends on where the missing file(s) are
located. Different actions are required when the bad files are in Accumulo data
table files or if they are metadata table files.

*Data File Corruption*

When an Accumulo data file is corrupt, the most reliable way to restore Accumulo
operations is to replace the missing file with an ``empty'' file so that
references to the file in the METADATA table and within the tablet server
hosting the file can be resolved by Accumulo. An empty file can be created using
the CreateEmpty utility:

    $ accumulo org.apache.accumulo.core.file.rfile.CreateEmpty /path/to/empty/file/empty.rf

The process is to delete the corrupt file and then move the empty file into its
place (The generated empty file can be copied and used multiple times if necessary and does not need
to be regenerated each time)

    $ hadoop fs –rm /accumulo/tables/corrupt/file/thename.rf; \
    hadoop fs -mv /path/to/empty/file/empty.rf /accumulo/tables/corrupt/file/thename.rf

*Metadata File Corruption*

If the corrupt files are metadata files, read the [system metadata tables][metadata]
(under the path `/accumulo/tables/!0`). Then, you will need to rebuild
the metadata table by initializing a new instance of Accumulo and then importing
all of the existing data into the new instance.  This is the same procedure as
recovering from a zookeeper failure (see next section), except that
you will have the benefit of having the existing user and table authorizations
that are maintained in zookeeper.

You can use the DumpZookeeper utility to save this information for reference
before creating the new instance.  You will not be able to use RestoreZookeeper
because the table names and references are likely to be different between the
original and the new instances, but it can serve as a reference.

If the files cannot be recovered, replace corrupt data files with a empty
rfiles to allow references in the metadata table and in the tablet servers to be
resolved. Rebuild the metadata table if the corrupt files are metadata files.

*Write-Ahead Log(WAL) File Corruption*

In certain versions of Accumulo, a corrupt WAL file (caused by HDFS corruption
or a bug in Accumulo that created the file) can block the successful recovery
of one to many Tablets. Accumulo can be stuck in a loop trying to recover the
WAL file, never being able to succeed.

In the cases where the WAL file's original contents are unrecoverable or some degree
of data loss is acceptable (beware if the WAL file contains updates to the Accumulo
metadata table!), the following process can be followed to create an valid, empty
WAL file. Run the following commands as the Accumulo unix user (to ensure that
the proper file permissions in HDFS)

    $ echo -n -e '--- Log File Header (v2) ---\x00\x00\x00\x00' > empty.wal

The above creates a file with the text "--- Log File Header (v2) ---" and then
four bytes. You should verify the contents of the file with a hexdump tool.

Then, place this empty WAL in HDFS and then replace the corrupt WAL file in HDFS
with the empty WAL.

    $ hdfs dfs -moveFromLocal empty.wal /user/accumulo/empty.wal
    $ hdfs dfs -mv /user/accumulo/empty.wal /accumulo/wal/tserver-4.example.com+10011/26abec5b-63e7-40dd-9fa1-b8ad2436606e

After the corrupt WAL file has been replaced, the system should automatically recover.
It may be necessary to restart the Accumulo Master process as an exponential
backup policy is used which could lead to a long wait before Accumulo will
try to re-load the WAL file.

## Zookeeper Failures

**I lost my ZooKeeper quorum (hardware failure), but HDFS is still intact. How can I recover my Accumulo instance?**

ZooKeeper, in addition to its lock-service capabilities, also serves to bootstrap an Accumulo
instance from some location in HDFS. It contains the pointers to the root tablet in HDFS which
is then used to load the Accumulo metadata tablets, which then loads all user tables. ZooKeeper
also stores all namespace and table configuration, the user database, the mapping of table IDs to
table names, and more across Accumulo restarts.

Presently, the only way to recover such an instance is to initialize a new instance and import all
of the old data into the new instance. The easiest way to tackle this problem is to first recreate
the mapping of table ID to table name and then recreate each of those tables in the new instance.
Set any necessary configuration on the new tables and add some split points to the tables to close
the gap between how many splits the old table had and no splits.

The directory structure in HDFS for tables will follow the general structure:

    /accumulo
    /accumulo/tables/
    /accumulo/tables/1
    /accumulo/tables/1/default_tablet/A000001.rf
    /accumulo/tables/1/t-00001/A000002.rf
    /accumulo/tables/1/t-00001/A000003.rf
    /accumulo/tables/2/default_tablet/A000004.rf
    /accumulo/tables/2/t-00001/A000005.rf

For each table, make a new directory that you can move (or copy if you have the HDFS space to do so)
all of the rfiles for a given table into. For example, to process the table with an ID of `1`, make a new directory,
say `/new-table-1` and then copy all files from `/accumulo/tables/1/\*/*.rf` into that directory. Additionally,
make a directory, `/new-table-1-failures`, for any failures during the import process. Then, issue the import
command using the Accumulo shell into the new table, telling Accumulo to not re-set the timestamp:

    user@instance new_table> importdirectory /new-table-1 /new-table-1-failures false

Any RFiles which were failed to be loaded will be placed in `/new-table-1-failures`. Rfiles that were successfully
imported will no longer exist in `/new-table-1`. For failures, move them back to the import directory and retry
the `importdirectory` command.

It is *extremely* important to note that this approach may introduce stale data back into
the tables. For a few reasons, RFiles may exist in the table directory which are candidates for deletion but have
not yet been deleted. Additionally, deleted data which was not compacted away, but still exists in write-ahead logs if
the original instance was somehow recoverable, will be re-introduced in the new instance. Table splits and merges
(which also include the deleteRows API call on TableOperations, are also vulnerable to this problem. This process should
*not* be used if these are unacceptable risks. It is possible to try to re-create a view of the `accumulo.metadata`
table to prune out files that are candidates for deletion, but this is a difficult task that also may not be entirely accurate.

Likewise, it is also possible that data loss may occur from write-ahead log (WAL) files which existed on the old table but
were not minor-compacted into an RFile. Again, it may be possible to reconstruct the state of these WAL files to
replay data not yet in an RFile; however, this is a difficult task and is not implemented in any automated fashion.

The `importdirectory` shell command can be used to import RFiles from the old instance into a newly created instance,
but extreme care should go into the decision to do this as it may result in reintroduction of stale data or the
omission of new data.

## Upgrade Issues

**I upgraded from 1.4 to 1.5 to 1.6 but still have some WAL files on local disk. Do I have any way to recover them?**

Yes, you can recover them by running the LocalWALRecovery utility (not available in 1.8 and later) on each node that needs recovery performed. The utility
will default to using the directory specified by `logger.dir.walog` in your configuration, or can be
overridden by using the `--local-wal-directories` option on the tool. It can be invoked as follows:

    accumulo org.apache.accumulo.tserver.log.LocalWALRecovery

**I am trying to start the master after upgrading but the upgrade is aborting with the following message:**
  `org.apache.accumulo.core.client.AccumuloException: Aborting upgrade because there are outstanding FATE transactions from a previous Accumulo version.`

You can use the shell to delete completed FATE transactions using the following:

* Start tservers
* Start shell
* Run `fate print` to list all
* If completed, just delete with `fate delete`
* Start masters once there are no more fate operations

If any of the operations are not complete, you should rollback the upgrade and troubleshoot completing them with your prior version.

## File Naming Conventions

**Why are files named like they are? Why do some start with `C` and others with `F`?**

The file names give you a basic idea for the source of the file.

The base of the filename is a base-36 unique number. All filenames in accumulo are coordinated
with a counter in zookeeper, so they are always unique, which is useful for debugging.

The leading letter gives you an idea of how the file was created:

* `F` - Flush: entries in memory were written to a file (Minor Compaction)
* `M` - Merging compaction: entries in memory were combined with the smallest file to create one new file
* `C` - Several files, but not all files, were combined to produce this file (Major Compaction)
* `A` - All files were compacted, delete entries were dropped
* `I` - Bulk import, complete, sorted index files. Always in a directory starting with `b-`

This simple file naming convention allows you to see the basic structure of the files from just
their filenames, and reason about what should be happening to them next, just
by scanning their entries in the metadata tables.

For example, if you see multiple files with `M` prefixes, the tablet is, or was, up against its
maximum file limit, so it began merging memory updates with files to keep the file count reasonable.  This
slows down ingest performance, so knowing there are many files like this tells you that the system
is struggling to keep up with ingest vs the compaction strategy which reduces the number of files.

## HDFS Decommissioning Issues

**My Hadoop DataNode is hung for hours trying to decommission.**

Write Ahead Logs stay open until they hit the size threshold, which could be many hours or days in some cases. These open files will prevent a DN from finishing its decommissioning process (HDFS-3599) in some versions of Hadoop 2. If you stop the DN, then the WALog file will not be closed and you could lose data. To work around this issue, we now close WALogs on a time period specified by the property `tserver.walog.max.age` with a default period of 24 hours.

[metadata]: {% durl troubleshooting/system-metadata-tables %}
