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
 1. pause non-snapshot fate ops (let them finish current step, but do not
    execute next step).   Temporarily stop accepting new FATE ops.
 1. pause Accumulo GC
 1. flush metadata table
 1. flush root table (probably need to to fix {% ghi 798 %})
 1. Create snapshot copying ZK to DFS (this is the snapshot assuming 
    {% ghi 936 %} is done)
 1. Unpause everything. When the GC is unpaused, it should start fresh reading
    all snapshots available.
 1. release snapshot lock

A user could optionally flush some or all tables before taking a snapshot.

More thought needs to be given to write ahead logs.  This design ignores them
and only concerns itself with flushed data.

Pausing FATE ops may not be needed.  More design work is needed in the general
area of FATE ops. Ideally the snapshot operation would be extemely fast.
Pausing FATE ops could be very slow.  The reason behind pausing is to get a
consistent view of FATE and the root+metadata tables.

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
