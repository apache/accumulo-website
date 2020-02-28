---
title: External Compaction Design
---

## Definitions

 * *External compaction:* compactions of a tablet execute in a process other than
   the tablet server hosting that tablet.

 * *Internal compaction:* compactions of a tablet execute in the tablet server
   process hosting the tablet.

 * *Compactor:* Accumulo process that runs external compactions.

## Introduction

Currently, Accumulo only supports internal compactions.  This can lead to
uneven load on a cluster.  For example, a few tablet servers could have many
tablets to compact while many tablet servers are idle.  If Accumulo supported
external compactions, then compaction work could evenly spread across a
cluster.

Compactors could start with a command like:

```
  accumulo compactor <queue>
```

This would start a process that looks for compactions on the specified
distributed queue and executes them.  The command could easily run in a docker
container in something like Kubernetes.  A compactor would need to continually
do the following

 * Find tablets with files to compact in the queue
 * Reserve files/work unit
 * Compact files
 * Commit compaction

This document outlines an alternative design to the one outlined in [#1451].
[#1451] proposes a pull+polling approach, early binding, leases and client side
selection. This proposal has a distributed queue supporting late binding
instead of the pull+polling approach.  Selection is in the tablet server
instead of an Accumulo client.  Zookeeper ephemeral nodes are used instead of
leases.

## Selection

Accumulo needs a mechanism to select files for compaction.  Currently this is
done in two ways.  The first way is by looking for tablets with too many files
according to a logarithmic size ratio.  The second way is when a user initiates
a compaction with a specified file selection criterion.  User initiated
compactions may also specify custom iterators that do things like filter out
unwanted data.

In both cases above, this selection code currently runs in the tablet server.
User can optionally pass configuration to the selection code running in the
tablet servers.  Going forward the selection code could run in three places.

 * In the tablet server.
 * In the compactor processes.
 * In a user process that initiates a user compaction.

Determining where selection code runs is an important consideration for the
overall user experience.  However, for this document its assumed that selection
code runs somewhere and queues compaction work.  One possibility for selection
is to use the approach outlined in [#564] with the additional capability of
compaction managers to submit jobs to distributed external compaction queues
(in addition to internal queues).

## Queues

A distributed queue for external compactions needs to support the following operations.

 * Adding and removing compaction work for a tablet
 * Prioritizing compaction work for a tablet
 * Efficiently finding work

One possibility to implement a distributed queue is a section in Accumulo’s
metadata table for each queue.  Giving each queue a unique row prefix within
the metadata table would cause it sort separately.  Below is a possible schema
for the row.

```
~cq:<queue id>:<bin>:<priority>:<table id>:<tablet end row>
```

| Field    | Purpose
| -------- | -------
| ~cq      | This prefix reserves ranges of the metadata table for compaction queues
| queue id | The ID of a compaction queue. Putting this field second in the sort order causes all entries for a single queue to sort together.
| bin      | Compaction queues have a fixed number of bins, each bin sorted by priority.  This exist to avoid hot spots while allowing prioritization.  A tablets bin is `hash(table id+end row) % numBins`.
| priority | A fixed size field for priority, possibly a 32 or 64 bit integer.
| table id | Table id of tablet that needs a compaction.
| end row  | Metadata end row of a tablet that needs compaction.  The table id and end row uniquely identify a tablet.

To find work, compactors would choose a random bin, take the highest priority
tablet, and attempt to reserve it for compaction. If the reservation fails this
could indicate there are too many compactors and too little work, so exponential
back off could be done.

## Reserving work

Currently with internal compactions, if a tablet server process dies then so do
all the compactions.  So, there is currently no need to track compactions
except in a tablet servers' memory. With external compactions the following
situations are possible.

 * Tablet server dies while external compaction processes are still running
 * compactions External compaction process dies while performing a compaction
 * Multiple external compactors attempt to run the same task

One way to handle these situations is the following

 * Each compactor process has an ephemeral node in zookeeper with an associated
   unique id.  This allows other processes to know if a compactor is alive or
   not.
 * Before starting work on a compaction, compactors reach out to the tablet
   server hosting the tablet and reserves the work using its unique id.
 * When tablets receive a reservation request, they check to ensure its not
   reserved.  If it is not, they will persist the reservation in the tablets
   section of the metadata table.  Persisting the reservation information
   handle the case of tablet server dying while an external compaction is
   running.
 * Whenever a tablet server notices an ephemeral node related to a compactor
   disappears, it will unreserve any related work.

After work is successfully reserved and a tablet has no more work for the
queue, remove the related entry in the distributed queue.

## Compactions

Running compactions is straightforward and well understood.  What needs to be
determined for external compactions is how parameters (iterators, summarizers,
table iterators, input files, output file, etc) pass between processes.  The
following are two ways to pass parameters

 * Store parameters as the value of the distributed work queue key.
 * The reservation RPC returns compaction parameters upon a successful
   reservation.

Having the reservation RPC return the compaction parameters has two advantages.
First it enables late binding where the tablet can compute what work needs to
do when it gets the request. Second it allows tablets to only delete the queue
entry when there is no more work to do.

## Committing

Once a compaction completes, the compactor lets the the tablet know via RPC.
Tablets will atomically do the following for this case.

 * Replace the compacted files with the new file
 * Delete the reservation

## Administration

In addition to running compactors, users will need to able to do the following operations

 * Create an external compaction queue.  This could pre-split the metadata
   table creating a configurable number of metadata tablets for the queue.
 * Delete an external compaction queue.  Deleting the compactors ephemeral node
   in zookeeper should cause all compactors to die.
 * List all external compaction queues
 * Obtain information about a specific external compaction queue like the
   number of compactions queued and running.
 * List compactors.

## Examples

The following is an example scenario of running a single compaction that tries
to show all the actions.

 * User creates a compaction queue named size256M using an Accumulo API or shell command.
   * A unique id of ca78 is allocated.
   * The value of /accumulo/compactors is a json map of names to ids.  An entry
     for size256M => ca78 is added and a check to see if the name exists is
     done.  This is all done atomically using zookeeper primitives.
   * /accumulo/compactors/ca78 is created in zookeeper.  Compactor processes
     will create their ephemeral nodes under this node.
   * Split points are created in the metadata table at `~cq:ca78` and `~cq:ca78:~`
 * User starts a compactor for size256M
   * Compactor creates an ephemeral sequential node under
     /accumulo/compactors/ca78. The path ca78/c-XXXXX servers as its ID.  The
     value of the node in ZK contains information about the compactor like
     where it is running.
   * The compactor start scanning the metadata table for work.  It does not
     find anything and rescans with exponential backoff up to a maximum time.
 * User configures table TABLE1 to queue compactions of files of more than 256M
   to size256M external compaction queue.
   * Per table configuration items are set
 * A tablet in TABLE1 determines it needs to compact a 100M, 120M, 100M, and
   90M file.  This compaction is queued.
   * A compaction entry of the form `~cq:ca78:004:000001:2:endrow` is written to
     the metadata table.
 * The compactor process scans the metadata table and sees the entry
   `~cq:ca78:004:000001:2:endrow`
   * The compactor looks up the tablet 2;endrow in the metadata table and
     obtains it location.
   * The compactor goes to that location and reserves the 4 files for
     compaction via RPC.
     * The tablet checks that compactor has an active ephemeral node in
       zookeeper and registers a watcher on it.
     * The tablet upon receiving this request computes what work needs to be
       done for the queue.  If the work that needs to be done is reserved or
       there is no work to do, it returns something indicating this and deletes
       the entry from the queue.
     * If there is work to do it records that compactor ca78/c-XXXXX has
       reserved the 4 files in the metadata table.
     * The entry `~cq:ca78:004:000001:2:endrow` is deleted from the queue if
       there is no other work do for that queue.
   * The reservation was successful, so the compactor starts running the compaction.
   * The compaction completes and the compactor commits it via an RPC to the tablet
     * The tablet receives the RPC and replaces the 4 old files with the new
       file and removes the reservation.
   * The compactor goes back to looking for work.

The following is an example scenario shows what happens when a compactor dies.

 * User creates a compaction queue named size256M using an Accumulo API or
   shell command.
 * User starts a compactor for size256M
 * User configures table TABLE1 to queue compactions of files of more than 256M
   to size256M external compaction queue.
 * A tablet in TABLE1 determines it needs to compact a 100M, 120M, 100M, and
   90M file.  This compaction is queued to size256M.
 * The compactor finds the work in the queue, reserves it, and start compacting
 * The compactor process dies causing its ephemeral node in zookeeper to
   eventually disappear.
 * Zookeeper notifies the tablet of the ephemeral node's deletion.  An
   alternative to notifications is that tservers could periodically scan active
   compactors using zoocache looking for changes. This should be very isolated
   in the code.
   * The tablet looks for any reservations related to the ephemeral node and
     deletes the ones it finds.  Canceling the reservations must be atomic to
     ensure if for any reason a commit RPC comes in that only one succeeds.
   * The tablet determines if anything needs to be requeued and does so if needed.

In the case when a tablet servers dies the following actions need to happen when the tablet is loaded on another tablet server.

 * The tablet needs to load and reservations from the metadata table.
 * If there are reservations, the tablet may need to register a zookeeper watch
   for compactors ephemeral nodes. This depends on how tablet servers implement
   watching compactors ephemeral nodes.

[#1451]: https://github.com/apache/accumulo/issues/1451
[#564]: https://github.com/apache/accumulo/issues/564
