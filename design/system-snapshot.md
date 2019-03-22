---
title: Accumulo System Snapshot Design
---

## Disclaimer

This is a work in progress design document for a feature that may never be
implemented.  It represents one possible design for {% ghi 1044 %}, but does
not have to be the only one.

## Overview

Being able to take snapshots of an entire Accumulo system and roll back to
snapshot would support many administrative use cases(outlined in
{% ghi 1044 %}).  This design outlines one possible way to implement snapshots.

The goal behavior is that a snapshot contains all data that was flushed or bulk
imported before the snapshot operation started.  A snapshot may contain
information written to a table while the snapshot operation is in progress.

Each snapshot would be an composed of an tree of immutable files in DFS.  This
tree would have the following three levels.

 * **Root Node**: A snapshot of all ZK metadata. This would be accomplished by
    copying all data in ZK into a file in DFS. This must be done correctly
    with concurrent operations. If {% ghi 936%} is implemented, then a
    snapshot of Zookeeper is a snapshot of everything needed.
 * **Internal nodes**: The root node would point a version of the root tablet in
    DFS. The root tablet snapshot would point to a version of the metadata
    tablets in DFS.
 * **Leaf nodes**:  The metadata nodes would point user table data in HDFS.
    This would form a snapshot of the data in each table.

The root snapshot node would also store info like per table config that is
stored in zookeeper, in addition to pointing to other files.

Snapshots would be stored as files in a `/accumulo/snapshots/` directory with a
copy on every volume.

The Accumulo GC would read all snapshots when deciding what files to delete. GC
would need to read blip markers in snapshot.

Storing all Accumulo snapshot data in DFS would work nicely with DFS snapshots.
Taking an Accumulo snapshot followed by a DFS snapshot could avoid certain
catastrophic administrative errors.  However, since Accumulo can work across
multiple DFS instances there is no requirement to use DFS snapshots.

## User operations

Users would be able to do the following operations.

 * Create a named snapshot.  The name must be unique.
 * Interrogate snapshot information.
   * List all snapshots.
   * List the files used by snapshot.
   * Print snapshot details (data version, accumulo version that created
     snapshot, tables, table config, system config, fate ops, etc). Should
     print this in such a way that it can be diffed using a text diff tool.
   * Analyze the space used by snapshots.  Could output a table that shows exclusive and shared space.
 * Restore Accumulo back to the state of a previous snapshot.
 * Delete a snapshot

## Implementation

### Creating a snapshot

A user API and related shell command would create snapshots.  The
implementation behind this API would create a FATE operation to do the
snapshot. The FATE op would do the following :

 1. get snapshot lock in ZK (prevents concurrent snapshot operations)
 1. ensure snapshot name is not in use
 1. pause changing props in ZK
 1. pause non-snapshot FATE ops (let running fate ops keep running, but pause
    any changes to the fate data store in ZK). 
 1. pause Accumulo GC
 1. flush metadata table
 1. flush root table (probably need to to fix {% ghi 798 %})
 1. TODO should the root and metadata table be checked for consistency?
    Ongoing split and FATE ops that may cause inconsistency should resolve after
    the snapshot is restored, so this seems uneeded.
 1. Create snapshot copying ZK to DFS (this is the snapshot assuming 
    {% ghi 936 %} is done)
 1. Unpause everything. When the GC is unpaused, it should start fresh reading
    all snapshots available.
 1. release snapshot lock

A user could optionally flush some or all tables before taking a snapshot.

More thought needs to be given to write ahead logs.  This design ignores them
and only concerns itself with flushed data.

The reason behind pausing FATE ops is to get a consistent view of FATE and the
root+metadata tables.  FATE ops are composed of a series of steps persisted in
zookeeper.  Each FATE step may mutate ZK, Accumulo metadata table, and/or HDFS.
Each FATE step is supposed to be idempotent meaning that in the case of failure
its safe to run it again.  Once a FATE step successfully completes, it expects
that any changes it made to other data stores (ZK, metadata table, etc) are
persisted.  The problem this design needs to solve is ensuring that data
related to completed FATE steps is present in the snapshot.  This guarantee
needs to be made in the face of concurrency.

Pausing changes to the FATE data store in Zookeeper before flushing the
metadata table is one way to solve this problem.  If a currently running FATE
step completes while a snapshot is running, then it will not be able to push
the next step in ZK. Pushing the next step in ZK would mark the current step as
complete/successful. This means that when a snapshot is restored it will force
any FATE steps that were running when the snapshot operation started to rerun.
When the step reruns it should redo any needed changes to the metadata table
and/or ZK.

All of the Pause operations could be started concurrently, waiting for all to
finish before proceeding.  Alternatively GC could be paused first and FATE last
in sequential order with the goal of minimizing latency for user operations.

### Listing snapshots

A user API and related shell command would list snapshots.  The implementation
would contact a random server which would read snapshot info from DFS.

### Restoring a snapshot.

A user API and related shell command would restore snapshots.  The
implementation would require that Accumulo be stopped.  It would check for this
in Zookeeper and place something in Zookeeper that keeps Accumulo from
starting.  One Accumulo is confirmed down and prevented from starting, it would
update everything needed in Zookeeper.   Updating some things in Zookeeper may
require special handling, like the unique name allocator data could possibly be
preserved.

### Deleting a snapshot.

A user API and related shell command would delete snapshots.  The
implementation could simply delete the related files `/accumulo/snapshots/`.
The GC would need to be tolerant of file being deleted while its reading them.
This could be a FATE op that get the snapshot lock.  That would handle the
case of deleting a snapshot that is in the process of being created more
gracefully.


### Accumulo GC changes

The Accumulo GC would need to support pausing.  This means it would finish its
current collection operation and not start another until unpaused.

The Accumulo GC reads a list of delete markers into memory.  Then it scans the
metadata table looking for delete markers that are in use.  When it finds a
delete maker is in use, it drops it from memory.  Any delete markers left in
memory result in deleting files.

For snapshots, Accumulo GC would need to read all of the files referenced by
each snapshot and use these to defeat delete markers.  This would be done in
addition to scanning the metadata table.  Since the files for snapshot are
immutable, the list of files for a snapshot could be computed once and stored.
This would make GC more efficient by avoiding random accesses to read the
metadata table snapshot.  The precomputed list of files could also contain size
info, which would be useful for analyzing space usage quickly.

### Upgrade and downgrade considerations.

For upgrade purposes the entire snapshot data schema should be designed with
upgrades and downgrades in mind. Suppose a user has the following snapshots

 * Snapshot S1 created by Accumulo 2.1
 * Snapshot S2 created by Accumulo 2.2

Suppose a user wants to run Accumulo 2.1 and restore snapshot S2.   This
implies that Accumulo 2.1 needs to be able to reliably read data from later
versions for GC purposes.  One possible way to solve this is to store garbage
collection information in its own versioned schema.  As long as 2.1 can read
the version of that schema, then the restoration can happen.

If a user is running Accumulo 2.2 they should be able to restore snapshots S2,
and S1 with some caveats.  The caveats are that S1 must have no FATE ops in
progress and the restorations should cause upgrade to run.  The reason upgrade
should run is because Zookeeper and Accumulo metadata may need to be updated.
The reason there can be no FATE ops is because upgrade disallows this.

The Accumuo upgrade process should check for snapshots and ensure it can
use/understand them.  If not, then the upgrade should fail.  For example if
Accumulo 2.6 can no longer read snapshot data from 2.1 then this should cause
upgrade to fail.

Below is a very incomplete example schema for the snapshot data file. It is
here to illustrate some of the points above, but is not well thought out.

```json
{
  "snapshot_schema_version" : 1
  "accumulo_version" : 2.1.2
  "zookeeper_data" : "serialized zookeeper snapshot"
  "garbage_collection_data" : {
     "schema_version" : 1
     "referenced_dirs" : []
     "referenced_files" : []
  }
}
```

## Possible problems

There are some possible problems aread this design does not explore in depth
that need more attention.

 * Evolution of volumes over time.  If snapshots have different volumes than
   each other and the current system, what are the implications of this for
   garbage collection?  Does the snapshot need to serialize the volume config?
 * Unique file names.  Accumulo gives each file it creates a globally unique
   file name.  If the system is rolled back to an older snapshot, with files
   from new snapshots still present, there is a potential for name collisions.
   What are the implications of this?
 * What else?
