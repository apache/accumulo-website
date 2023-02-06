---
title: FATE
category: administration
order: 3
---

Accumulo must implement a number of distributed, multi-step operations to support
the client API. Creating a new table is a simple example of an atomic client call
which requires multiple steps in the implementation: get a unique table ID, configure
default table permissions, populate information in ZooKeeper to record the table's
existence, create directories in HDFS for the table's data, etc. Implementing these
steps in a way that is tolerant to node failure and other concurrent operations is
very difficult to achieve. Accumulo includes a Fault-Tolerant Executor (FATE) which
is widely used server-side to implement the client API safely and correctly.

Fault-Tolerant Executor (FATE) is the implementation detail which ensures that tables in
creation when the Manager dies will be successfully created when another Manager process is
started. This alleviates the need for any external tools to correct some bad state -- Accumulo
can undo the failure and self-heal without any external intervention.

## Overview

FATE consists of two primary components: a repeatable, persisted operation (REPO), a storage
layer for REPOs and an execution system to run REPOs. Accumulo uses ZooKeeper as the storage
layer for FATE and the Accumulo Manager acts as the execution system to run REPOs.

The important characteristic of REPOs are that they implemented in a way that is idempotent:
every operation must be able to undo or replay a partial execution of itself. Requiring the
implementation of the operation to support this functional greatly simplifies the execution
of these operations. This property is also what guarantees safety in light of failure conditions.

### REPO Stack

A FATE transaction is composed of a sequence of Repeatable persisted operations (REPO).  In order to start a FATE transaction,
a REPO is pushed onto a per-transaction REPO stack.  The top of the stack always contains the
next REPO the FATE transaction should execute.  When a REPO is successful it may return another
REPO which is pushed on the stack.

### FATE Structure in ZooKeeper

The storage layer in ZooKeeper is organized by storing each FATE transaction in a unique path based
on the FATE transaction id. The base path for FATE transactions is:

```
/accumulo/[INSTANCE_ID]/fate/tx_[TXID]
```

The data stored on the transaction id node provides the current FATE transaction status (e.g. NEW, IN_PROGRESS,
SUCCESS, FAILED,...)

Under the transaction id node, there will be a number of REPOs and a debug node that provides additional
information. The debug information is added when the transaction is created and is the command class simple name.
The REPOs form a stack of operations that will be performed in order and in ZooKeeper are numbered `repo_0000000000`
to `repo_#` The REPO with the largest number is the top of the stack. The top of the stack is the REPO currently
running or the next REPO that will start on the next execution. The REPO with the lowest number
(usually repo_0000000000) is the operation that spawned the FATE operations.

```
Sample FATE ZooKeeper paths:

/accumulo/dcbf6855-8eac-4b44-a4a9-7ad39caafe9a/fate/tx_4dd46d49d60f1a17
/accumulo/dcbf6855-8eac-4b44-a4a9-7ad39caafe9a/fate/tx_4dd46d49d60f1a17/debug
/accumulo/dcbf6855-8eac-4b44-a4a9-7ad39caafe9a/fate/tx_4dd46d49d60f1a17/repo_0000000002
/accumulo/dcbf6855-8eac-4b44-a4a9-7ad39caafe9a/fate/tx_4dd46d49d60f1a17/repo_0000000000

```

## Administration

Sometimes, it is useful to inspect the current FATE operations, both pending and executing.
For example, a command that is not completing could be blocked on the execution of another
operation. Accumulo provides an Accumulo shell command to interact with fate.

The `fate` admin command accepts a number of arguments for different functionality:
`list`/`print`, `summary`, `cancel`, `fail`, `delete`, `dump`.

The command for launching the fate admin command is:

```
> accumulo admin fate --[option]
```

The Accumulo admin help command option `accumulo admin -h` shows the expected usage information for the fate and
other admin commands.

### List/Print

Without any additional arguments, this command will print all operations that still exist in
the FATE store (ZooKeeper). This will include active, pending, and completed operations (completed
operations are lazily removed from the store). Each operation includes a unique "transaction ID", the
state of the operation (e.g. `NEW`, `SUBMITTED`, `IN_PROGRESS`, `FAILED`), any locks the
transaction actively holds and any locks it is waiting to acquire.

This option can also accept transaction IDs which will restrict the list of transactions shown.

### Summary (new in 2.1)

Similar to the List/Print command, this command prints a snapshot of all operations in the FATE store (ZooKeeper).
The information includes summary counts of:

  * Operation States (`NEW`, `SUBMITTED`, `IN_PROGRESS`, `FAILED`)
  * The FATE transaction commands
  * The current executing steps
  * Expanded FATE information details

The expanded FATE details supplement the information provided by list/print by including the running duration since the
FATE was created, the names of the namespace and tables for locks the transaction holds or is waiting to acquire.
(Note: depending on the operation and the step, the expanded details fields may be incomplete or unknown when the
snapshot information is gathered.)

This option accepts a filter for the details section by the state of the operation
(e.g. `NEW`, `SUBMITTED`, `IN_PROGRESS`, `FAILED`). The command also provides the option to output the information
formatted as json.

Sample output:

```
Report Time: 2022-07-07T11:42:02Z
Status counts:
  IN_PROGRESS: 2

Command counts:
  CompactRange: 2

Step counts:
  CompactionDriver: 2

Fate transactions (oldest first):
Status Filters: [NONE]

Running txn_id              Status      Command         Step (top)          locks held:(table id, name)             locks waiting:(table id, name)
0:00:04 0c143900c230c1df    IN_PROGRESS CompactRange    CompactionDriver    held:[R:(1,ns:ns1), R:(2,t:ns1.table1)] waiting:[]
0:00:03 55f59a2ae838e19e    IN_PROGRESS CompactRange    CompactionDriver    held:[R:(1,ns:ns1), R:(2,t:ns1.table1)] waiting:[]

```
### Cancel

This command can be used to cancel NEW or SUBMITTED FATE transactions. This command requires
one or more transaction ids.

### Fail

This command can be used to manually fail a FATE transaction and requires a transaction ID
as an argument. Failing an operation is not a normal procedure and should only be performed
by an administrator who understands the implications of why they are failing the operation.

### Delete

This command requires a transaction ID and will delete any locks that the transaction
holds. Like the fail command, this command should only be used in extreme circumstances
by an administrator that understands the implications of the command they are about to
invoke. It is not normal to invoke this command.

### Dump

This command accepts zero more transaction IDs.  If given no transaction IDs,
it will dump all active transactions.  A FATE operations is compromised as a
sequence of REPOs.  In order to start a FATE transaction, a REPO is pushed onto
a per-transaction REPO stack.  The top of the stack always contains the next
REPO the FATE transaction should execute.  When a REPO is successful it may
return another REPO which is pushed on the stack.  The `dump` command will
print all of the REPOs on each transactions stack.  The REPOs are serialized to
JSON in order to make them human-readable.
