---
title: "Accumulo Scan Servers"
author: Dave Marion
---

## Introduction

Apache Accumulo Tablet Servers perform many tablet maintenance functions (read, write, compacting, merging, splitting, etc.). Since Tablet Servers typically host many tablets these tablet maintenance functions can be queued waiting for resources or interrupted when the Manager decides to migrate a tablet or if the Tablet Server process dies. Scan Servers, like Compactors, move processing out of the Tablet Server to help mitigate some of these situations. A Scan Server is an optional, read-only Accumulo process that handles eventually consistent scans independently of Tablet Servers. Administrators can deploy and scale Scan Servers according to scan demand, providing additional read capacity without adding the responsibilities of hosting tablets or processing writes. Beginning in Accumulo 2.1.5, Scan Servers can also scan offline tables.

Using Scan Servers comes with an explicit consistency tradeoff. Tablet Servers can serve immediate scans using both persisted files and data still held in memory. Scan Servers instead read persisted RFiles, so an eventual scan may not include recent writes that have not yet been flushed. Cached tablet metadata can also affect when newly created files become visible. Scan Servers are therefore a strong fit for reporting, historical analysis, and background processing, but not for operations that require read-after-write consistency.

This post explains how Scan Servers work and how to configure them on the server and client sides. It begins with the feature model introduced in Accumulo 2.1.0 and concludes with the behavioral and configuration changes to consider when using Accumulo 4.0.0.

## How Scan Servers Work

### Immediate and Eventual Consistency

Accumulo exposes Scan Server behavior through the scanner's consistency level. The default consistency level, `IMMEDIATE`, sends scan requests to Tablet Servers and includes data that has been successfully written but may still be held in memory. Setting the consistency level to `EVENTUAL` makes the scan eligible for Scan Server execution. The configured selector chooses a Scan Server or, where fallback is enabled, directs the request to the tablet's Tablet Server.

Applications opt in to this behavior on either a `Scanner` or a `BatchScanner` by setting the consistency level to `EVENTUAL`:

```java
scanner.setConsistencyLevel(ScannerBase.ConsistencyLevel.EVENTUAL);
```

### Scan Execution

For an eventual scan, the client discovers the available Scan Servers and uses its configured `ScanServerSelector` to choose a server for each tablet. This client-side selection distributes work across the Scan Server pool and allows different classes of scans to target different server groups. The selected Scan Server then creates a Tablet from its metadata, if one does not already exist in the cache, to execute the scan over the RFiles for that tablet. Before reading those files, the Scan Server records references that prevent Accumulo's garbage collector from deleting them. References that are no longer used expire and can be removed. If the Scan Server cannot perform the requested action it sends a busy signal back to the client, allowing the client to select a different Scan Server for the scan operation.

## Server-Side Configuration in Accumulo 2.1.0

Scan Servers are optional, so an administrator must start them in addition to the other Accumulo services. In Accumulo 2.1.0, the following command starts a Scan Server in the default group:

```bash
accumulo-service sserver start
```

A named group is supplied to the Scan Server process with `-g` or `--group`:

```bash
accumulo-service sserver start -g analytics
```

The group is a label used by clients when selecting servers. It is not a persistent configuration object in 2.1.0. For cluster-managed deployments, `cluster.yaml` maps each group to its hosts and uses one global process count for all Scan Server groups:

```yaml
sserver:
  - long_scans_group:
    - host1
    - host2

sservers_per_host: 2
```

This example starts two Scan Server processes on each host assigned to the `long_scans_group` group. Running multiple processes can increase concurrency, but each process has its own heap and caches, so the count should be chosen together with the per-process memory settings.

### Important Server Properties

The initial Scan Server configuration used the `sserver.*` property prefix. The most important 2.1.0 defaults are shown below.

| Property | 2.1.0 default | Purpose |
|---|---:|---|
| `sserver.port.client` | `9996` | Port for client connections |
| `sserver.port.search` | `true` | Search for an available port when the configured port is occupied |
| `sserver.server.message.size.max` | `1G` | Maximum incoming RPC message size |
| `sserver.server.threads.minimum` | `2` | Minimum number of RPC request threads |
| `sserver.cache.data.size` | `10%` | Cache for RFile data blocks |
| `sserver.cache.index.size` | `25%` | Cache for RFile index blocks |
| `sserver.cache.summary.size` | `10%` | Cache for summary data |
| `sserver.default.blocksize` | `1M` | Default block size for Scan Server caches |
| `sserver.cache.metadata.expiration` | `5m` | Lifetime of cached tablet metadata |
| `sserver.scan.executors.default.threads` | `16` | Threads for the default scan executor |
| `sserver.scan.executors.meta.threads` | `8` | Threads for metadata scans |
| `sserver.scan.reference.expiration` | `5m` | Time an unused file reference is retained |

The RPC thread pool receives client requests, but scan executor threads control how many scans can execute concurrently (see [scan-executors][https://accumulo.apache.org/docs/2.x/administration/scan-executors]).

### Controlling Latency

Scan Servers only see data persisted from the Tablet Server via a minor compaction and will only use new files if the Tablet metadata is not cached. In 2.1.0 two configuration properties control the flushing of tablet metadata and tablet metadata cache expiration. They are `table.compaction.minor.idle` and `sserver.cache.metadata.expiration`. In version 2.1.3 the `sserver.cache.metadata.refresh.percent` property was added to trigger a preemptive tablet metadata reload into the cache.

## Client-Side Configuration in Accumulo 2.1.0

### Selecting Scan Servers

Scan Server selection is controlled by a client-side SPI. The default implementation is `ConfigurableScanServerSelector`:

```properties
scan.server.selector.impl=org.apache.accumulo.core.spi.scan.ConfigurableScanServerSelector
scan.server.selector.opts.profiles=[...]
```

The `profiles` value is a JSON array. Exactly one profile must set `isDefault` to `true`. Other profiles can be activated by setting a `scan_type` execution hint on a scanner. Each profile can identify a Scan Server group and define one or more attempt plans.

```json
[
  {
    "isDefault": true,
    "maxBusyTimeout": "5m",
    "busyTimeoutMultiplier": 8,
    "attemptPlans": [
      {"servers": "3", "busyTimeout": "100ms"},
      {"servers": "100%", "busyTimeout": "1s"}
    ]
  },
  {
    "scanTypeActivations": ["analytics"],
    "group": "analytics",
    "maxBusyTimeout": "10m",
    "busyTimeoutMultiplier": 8,
    "attemptPlans": [
      {"servers": "3", "busyTimeout": "5s"},
      {"servers": "100%", "busyTimeout": "30s", "salt": "retry"}
    ]
  }
]
```

Within an attempt plan, `servers` is either a positive count or a percentage of the available Scan Servers in the group. The client-side selector hashes the tablet to a candidate set and chooses a server from that set. `busyTimeout` limits how long a request may remain queued in the Scan Server before it begins executing. If the `busyTimeout` threshold is met, then the Scan Server returns a busy signal to the client so that it can select a different Scan Server. An optional `salt` changes the hash for a later attempt so that the client can consider a different candidate set.

## Use with offline tables

Accumulo 2.1.5 enabled Scan Servers to work with offline tables. The later section on Accumulo 4.0 discusses an important compatibility change for this feature.  

## Use with specific tables

Accumulo 2.1.5 added the property `sserver.scan.allowed.tables.group.<group>`. Its default value permits user tables outside the `accumulo` namespace. Use caution if allowing Scan Servers to be used with tables in the `accumulo` namespace, as the information will be stale. The later section on Accumulo 4.0 discusses an important compatibility change for this feature.

## Changes Through Accumulo 4.0.0

The scanner-facing API remains unchanged, but client configuration and behavior, and server-side options have changed.

### No-Server Behavior and Selection

The most visible client behavior change occurs when the selected group contains no live Scan Servers. In 2.1.0, the default selector immediately fell back to a Tablet Server. The 4.0.0 version of the ConfigurableScanServerSelector defaults `timeToWaitForScanServers` to approximately 100 years which has the effect of never falling back to Tablet Servers. Set `timeToWaitForScanServers` to `0s` when immediate Tablet Server fallback is desired:

```json
[
  {
    "isDefault": true,
    "maxBusyTimeout": "5m",
    "busyTimeoutMultiplier": 8,
    "timeToWaitForScanServers": "0s",
    "attemptPlans": [
      {"servers": "3", "busyTimeout": "100ms"},
      {"servers": "100%", "busyTimeout": "1s"}
    ]
  }
]
```

The 4.0.0 selector also uses rendezvous hashing, avoids previously attempted servers when alternatives are available, and applies exponential client-side delay after RPC errors. Deployments that run multiple Scan Servers on each host can select `ConfigurableScanServerHostSelector`, which first maps tablets to hosts and then distributes work among servers on the selected host.

### First-Class Resource Groups

Scan Server groups evolved from process labels into first-class resource groups. The `sserver.group` property arrived in Accumulo 3.0.0, replacing the original `-g` argument. In Accumulo 4.0.0, `ResourceGroupOperations` provides persistent group-specific configuration, and a Scan Server receives the effective configuration for its group.

Create a non-default group before starting processes assigned to it. From the shell:

```text
createresourcegroup highmem
```

Start one process directly with a property override:

```bash
accumulo-service sserver start -o sserver.group=highmem
```

For cluster-managed deployments, `cluster.yaml` now supports a process count for each group:

```yaml
sserver:
  default:
    servers_per_host: 2
    hosts:
      - host1
      - host2
  highmem:
    servers_per_host: 1
    hosts:
      - host3
      - host4
```

The cluster script can also start only the selected group:

```bash
accumulo-cluster start --sservers=highmem
```

A client profile still uses the `group` field, but that value now identifies a resource group:

```json
[
  {
    "isDefault": true,
    "maxBusyTimeout": "5m",
    "busyTimeoutMultiplier": 8,
    "timeToWaitForScanServers": "0s",
    "attemptPlans": [
      {"servers": "3", "busyTimeout": "100ms"}
    ]
  },
  {
    "scanTypeActivations": ["analytics"],
    "group": "highmem",
    "maxBusyTimeout": "10m",
    "busyTimeoutMultiplier": 8,
    "attemptPlans": [
      {"servers": "3", "busyTimeout": "5s"},
      {"servers": "100%", "busyTimeout": "30s"}
    ]
  }
]
```

### Controlling Latency

In 4.0.0 the property `table.compaction.minor.age` replaces `table.compaction.minor.idle`. The latter property only triggered a minor compaction when writes to the Tablet had stopped and the tablet was idle. The `minor.age` property now considers the oldest in-memory mutation for the tablet and triggers a minor compaction even with writes continuing. The `table.compaction.minor.age` has a default value of 10 minutes.

### Server Property Changes

Many cache and executor settings retain their original names and defaults. The network, access-control, metadata-cache, and recovery settings have changed more substantially.

| Property | 2.1.0 | 4.0.0-SNAPSHOT |
|---|---:|---:|
| `sserver.port.client` | `9996` | `9700-9799` |
| `sserver.port.search` | `true` | Removed |
| `sserver.server.message.size.max` | `1G` | Removed; use `rpc.message.size.max` |
| `sserver.server.threads.minimum` | `2` | `20` |
| `sserver.cache.metadata.expiration` | `5m` | `5m` |
| `sserver.cache.metadata.refresh.percent` | Not available | `.75` |
| `sserver.group` | Not available | `default` |
| `sserver.scan.allowed.tables` | Not available | Rejects `accumulo.*` by default |
| `sserver.wal.sort.concurrent.max` | Not available | `2` |

The 4.0.0 `sserver.port.client` value is a range, so the old `sserver.port.search` switch is no longer needed. The Scan Server-specific RPC message limit was also removed in favor of the shared `rpc.message.size.max` property.

Background tablet-metadata refresh was added in 2.1.3. With the current defaults, a cache hit after 75 percent of the five-minute expiration interval starts an asynchronous refresh for future scans. The scan that triggers that work can still use the existing cached value, so this mechanism improves freshness without guaranteeing it.

Table filtering first appeared in 2.1.5 as `sserver.scan.allowed.tables.group.<group>`. Accumulo 4.0.0 replaces that group-suffixed property with `sserver.scan.allowed.tables` in the resource group's effective configuration.

Accumulo 4.0.0 also allows Scan Servers to perform the sorting phase of write-ahead log recovery to help enable faster Tablet recovery. The default `sserver.wal.sort.concurrent.max=2` permits two concurrent sorts; a value below one disables the work. When the write-ahead log recovery sorting phase is completed, the Tablet will be assigned to a Tablet Server to have the sorted mutations replayed. 

### File References and Graceful Shutdown

In 2.1.0, Scan Server file references were stored in a section of the metadata table. Accumulo 4.0.0 stores them in the dedicated `accumulo.scanref` system table, reducing contention with ordinary metadata operations.

The current graceful-shutdown path rejects new single and batch scans as busy, allows active scan sessions to drain, stops the RPC service, and removes the process's file references. References left by a failed server are eventually cleaned up. Administrators can invoke the cleanup utility when necessary to remove references from dead Scan Server using the command:

```bash
accumulo inst remove-scan-server-references
```

### Offline-Table Compatibility

Offline-table Scan Server support was added to the 2.1 line in Accumulo 2.1.5, but it is not available through the public client scanner APIs in the current 4.0.0-SNAPSHOT. In 4.0.0 users can set a tables availability to `UNHOSTED` to achieve the same thing.

## Upgrade Checklist

Before moving a Scan Server deployment from a 2.1.x release to Accumulo 4.0.0:

1. Replace the `-g <group>` process argument with `-o sserver.group=<group>`.
2. Create each non-default resource group before starting its Scan Servers.
3. Convert `cluster.yaml` from a global `sservers_per_host` value to per-group `servers_per_host` values.
4. Decide whether clients should retain the new waiting behavior or set `timeToWaitForScanServers` to `0s` for immediate fallback.
5. Replace the single client port and `sserver.port.search` with an appropriate `sserver.port.client` range.
6. Replace `sserver.server.message.size.max` with the shared `rpc.message.size.max` property when a custom limit is needed.
7. Account for the increase in `sserver.server.threads.minimum` from `2` to `20` when sizing processes.
8. Move 2.1.5-era `sserver.scan.allowed.tables.group.<group>` rules to the corresponding resource group's `sserver.scan.allowed.tables` property.
9. Review the default restriction on tables in the `accumulo` namespace.
10. Reevaluate freshness assumptions after enabling asynchronous metadata refresh.
11. Review any dependency on 2.1.5 offline-table scanning because the current 4.0.0-SNAPSHOT public API does not support it.

