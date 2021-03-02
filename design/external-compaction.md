---
title: External Compactions
---

# Definitions


  * *External compaction*: compactions of a tablet that execute in a process other than the tablet server hosting that tablet.

  * *Internal compaction*: compactions of a tablet that execute in the tablet server process hosting the tablet.
   
  * *Compaction Coordinator*: a process that manages the compaction queue of all external compactions in the system and assigns Compaction tasks to Compactors

  * *Compactor*: Accumulo process that runs external compactions. This process will only run a single compaction at a time.

# Internal Compactions

Currently all compactions are done internally in the TabletServer via the CompactionManager and a set of related objects.

## Components

  * *CompactionManager*: an object in the TabletServer that creates named (which defaults to root, meta and default) CompactionServices and runs compactions on Tablets in the CompactionService that is assigned to the Table

  * *CompactionService*: an object that is configured with a CompactionPlanner class name, a read/write rate limit, and other options required by the CompactionPlanner implementation. When the CompactionManager tells the CompactionService to compact a Tablet, the CompactionService uses the CompactionPlanner to determine which CompactionExecutor to use for running the compaction

  * *CompactionPlanner*: an object that is configured to create CompactionExecutors and determine which one to use for compacting a Tablet.

  * *CompactionExecutor*: an object that contains some number of configurable Threads in which to run compactions

  * *Compaction Dispatcher*: a per table pluggable component that decides which compaction service tablets will use for different kinds of compactions.  For example it may dispatch USER compactions to one service and SYSTEM compactions to another. 

## Overview

The CompactionManager operates on the set of online hosted tablets and calls CompactionManager::compact which uses the Table's configurable Compaction Dispatcher to determine which CompactionService to use for compacting the tablet for the specified type of operation (USER, SYSTEM, etc). Once the CompactionService is determined, the CompactionManager calls CompactionService::compact passing in the Tablet information and type of compaction. The CompactionService uses the CompactionPlanner to determine the plan (which files need to be compacted, which queue to use based on file sizes, etc), then executes the plan using CompactionExecutors. 

There are short-circuits along this path when compactions are already queued for the tablet and other cases which are not described here. For internal compactions the CompactionService keeps track of the queued and running compaction tasks.

![Image of Internal Compactions](https://github.com/dlmarion/accumulo-website/tree/external-compaction-design/design/internal_compactions.png)
  
## Configuration

The CompactionManager operates on the set of online tablets hosted by the TabletServer. The CompactionManager contains a set of CompactionServices where each CompactionService is initialized with a CompactionPlanner class name, read and write rates, and other options using the following properties:

  * *tserver.compaction.major.service.<service>.planner*: the fully qualified CompactionPlanner implementation class name for the service <service>.

  * *tserver.compaction.major.service.<service>.rate.limit*: maximum number of bytes to read or write per second for all compactions in this service.

  * *tserver.compaction.major.service.<service>.planner.opts.**: other properties used to configure the planner.


The DefaultCompactionPlanner implementation is configured to create multiple queues from the configuration where each queue is configured with file size thresholds and the number of threads. For example, the DefaultCompactionPlanner is configured by the following properties:


  * *tserver.compaction.major.service.<service>.planner.opts.executors*: a json array where each object in the array has the fields name, maxSize, and numThreads. For example:

```  
[
  {'name':'small','maxSize':'32M','numThreads':2},
  {'name':'medium','maxSize':'128M','numThreads':2},
  {'name':'large','numThreads':2}
]
```

  * *tserver.compaction.major.service.<service>.planner.opts.maxOpen*: number of files that will be included in a single compaction


# External Compactions

External compactions are major compactions (partial or full) that occur outside of the Tablet Server using the following set of components:

## Components

  * *CompactionCoordinator*: a component that maintains a global external compaction queue and schedules compactions for execution in a Compactor.

  * *Compactor*: a process that asks the CompactionCoordinator for work and performs compactions one at a time for a specified external queue.
  
## Overview
A CompactionService could be defined to use a Planner that has the ability to create internal and/or external CompactionExecutors. For example, let’s say that the configuration for this service is:

```
tserver.compaction.major.service.<service>.planner.opts.executors -
[
  {'name':'small','maxSize':'32M','numThreads':2},
  {'name':'medium','maxSize':'128M','numThreads':2},
  {'name':'large', ‘externalQueue’:’EQ1’}
]
```

This planner would create CompactionExecutor’s for the internal queues and a new ExternalCompactionExecutor for the external queue. When ExternalCompactionExecutor::submit is called this Executor would send a request to the CompactionCoordinator to queue the compaction request for execution on external queue EQ1. The CompactionCoordinator adds this request to the list of requests from all TabletServers. Compactor processes that are running will request the next compaction task from the CompactionCoordinator when they are free to do work and will notify the CompactionCoordinator when the compaction has completed (or failed)

## APIs

### Compaction Coordinator RPC API

```
/**
 * Called by tablet servers to get the status of compaction
**/
ExternalCompactionStatus[] getCompactionStatus(TabletId[])


/**
 * Called by tablet servers to get the number of running and queued compaction requests
**/
ExternalCompactionStats getCompactionStats(TabletId, String queueName)


/**
 * Called by compactor processes to get work to do for a queue.  The compactor Id can be used    to check if the process is alive. The implementation will find the top tablet in its queue and then    call reserveJob for that tablet on the tablet server.  This could be a blocking RPC call where it does not return until there is work, however not sure how well this will work.
 */
CompactionJob getCompactionJob(String queueName, CompactorId)


/**
 * Called by compactor process to indicate work is done. The implementation will call  finishedJob on the tablet servers.
 **/
void finishedJob(CompactionJob, CompactionStats)


/**
  * Called by compactor process to update the coordinator with the state of the running compaction
 **/
void updateCompactionStatus(CompactionJob, State, message, timestamp)
```

### Compactor RPC API

```
/**
  * Called by CompactionCoordinator to cancel the compaction work
**/
void cancel(CompactionJob)
```

### Tablet Server Compaction RPC API

```
/**
  Summary information about a tablet servers external compaction queue.
 */
Class TabletServerCompactionQueueSummary {
  // the name of an external queue for which information is summarized
  Sting queueName;
   // the priority for which this information is summarized
   Long priority;
   // the number of tablets queued on a tserver for a given queue and priority
   Int queuedCount;
}


/**
 * Called by the coordinator to get summary information about all of a tablets servers external compaction queues.
 */
List<TabletServerCompactionQueueSummary> getTabletServerQueueInfo()


/**
 * Called to atomically reserve compaction work for a tablet on a given queue with a priority level >= than what was passed.  Will return null if there is no work meeting criteria.  Tablets will treat these files reserved as part of a running compaction for planning future compactions. Will use CompactorId to check if process running compactions is alive.  Information about the reservation will be persisted by the tablet in the metadata table so that if the tablet loads elsewhere it will not lose track of the external compaction.
 */
CompactionJob reserveJob(String queueName, long priority, CompactorId)


/**
 * Atomically updates a tablets files after a compaction finishes. Called by CompactionCoordinator when Compactor finishes compaction
 */
void finishedJob(CompactionJob)
```

## Queue Specification

The CompactionCoordinator is responsible for managing the work queue. For each external compaction queue, the tablet server will maintain an internal in memory priority queue of the tablets loaded on it that have work to do on that external queue. The coordinator polls all tservers to get summary information about their external compaction queues. The coordinator then combines the summary information from all tservers and uses it to determine which tablet server to contact next to get work.  The coordinator does not maintain per tablet information, it only maintains enough information to allow it know which tablet server to contact for a given queue.  The tablet server will then know what specific tablet in that queue needs to compact.  

The coordinator could take the summary information and organize it as follows for each external compaction queue.  Then for a given compaction queue it knows which tservers currently have work.  For example in the picture below tservers ts1,ts9 and ? have work at priority level 7 for some queue. The coordinator could possibly round robin requests among the tservers of the highest priority level until that priority level is empty.

![Image of Coordinator Queue](https://github.com/dlmarion/accumulo-website/tree/external-compaction-design/design/coordinator_queue.jpg)

When the coordinator calls getTabletServerQueueInfo() on a tsever via RPC, it would need to take the information returned by the tserver and reconcile it with its global summary of information adding and removing the tserver from priority levels as needed.
This information could potentially be kept in memory in a structure of the form Map<QueueName, SortedMap<Priority, LinkedHashSet<Tserver>>> and when the coordinator starts it polls tservers and constructs the global queue summary map.  Periodically the coordinator could ask tservers for updated summaries and/or the reserveJob RPC call to tservers could return updated summary information.


## Workflow

When the coordinator polls a tserver to get its latest external queue summaries the following could happen:

  1. The tserver returns the latest summary information for all of its external compaction queues.
  2. The coordinator will add the tserver to priorities that it is not present in in the global queue summary map.
  3. The coordinator will remove the tserver from priorities that is in in the global queue summary map, but it is not in the summaries just returned by the tserver
  4. If needed the next tserver pointer in the global queue summary map will be updated.

On request for work from a compactor
  1. For the queue requested, the coordinator gets the next tserver from the global queue summary map.
  2. The Coordinator contacts the tablet server to reserve job
  3. Return compaction job information to compactor
  4. This must handle concurrent requests properly while minimizing the amount of locking.

## Metrics

TServers will each maintain their own internal queues for external compaction queues with all tablets.  If each tserver emits metrics about their local queues, then sum of all tserver metrics will give information about the external queues across the cluster.

Compactor should emit metrics about the number of compactions running and which queue they are running on.

## Scenarios

Scenario 1

 1. Tablet T1 has files F1,F4,F5,F6
 1. The compaction of files F4,F5,F6 is queued on external executor EE2 for Tablet T1
 1. A new file F7 arrives for T1
 1. The compaction of F4,F5,F6 on EE2 is canceled and new a compaction of F4,F5,F6,F7 is queued on EE2 for Tablet T1
 1. A new file F8 arrives for T1
 1. The compaction of F4,F5,F6,F7 on EE2 is canceled and new a compaction of F4,F5,F6,F7,F8 is queued on EE2 for Tablet T1

Scenario 2

 1. Tablet T1 has files F1,F2,F3,F4
 1. Compaction of files F1,F2,F3 is queued on internal executor IE1 for Tablet T1
 1. New files F5,F6,F7,F8,F9 arrive for tablet T1
 1. The compaction of F1,F2,F3 on IE1 is canceled and a new compaction of F1,F2,F3,F4,F5,F6,F7,F8,F9 is queued on external Executor EE2 for Tablet T1

Scenario 3
1. Tablet T1 has files F1,F2,F3
2. Compaction of files F1,F1,F3 is queued on external executor EE2 for T1
3. The table containing tablet T1 is deleted
4. A compactor tries to compact F1,F2,F3 for tablet T1 and hopefully fails cleanly


Scenario 4
1. Compaction of files F1,F1,F3 is queued on external executor EE2 for T1
2. The tablet server hosting tablet T1 dies
3. Tablet T1 is loaded elsewhere 
4. Compaction of files F1,F1,F3 is again queued on external executor EE2 for T1


Scenario 5
1. Compaction of files F1,F1,F3 is queued on external executor EE2 for T1
2. A compactor starts compacting F1,F2,F3 for T1
3. The tablet server hosting T1 dies
4. The compactor compacting F1,F2,F3 for T1 finishes (T1 is not hosted anywhere yet)
5. Another tablet server starts hosting T1
6. The compactor is able to commit the compaction of F1,F2,F3 for T1


Scenario 6
1. Compaction of files F1,F1,F3 is queued on external executor EE2 for T1
2. Compaction of files F4,F5,F6 is queued on external executor EE2 for T2
3. A compactor start compacting F1,F2,F3 for T1
4. The table hosting tablets T1 and T2 is taken offline
5. The compactor working on F1,F2,F3 for T1 finishes and cleanly fails to commit the compaction because the table is offline
6. The compaction for F4,F5,F6 is taken out of the queue, but cleanly fails to start because the table is offline.