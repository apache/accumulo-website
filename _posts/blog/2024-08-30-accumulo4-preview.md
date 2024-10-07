---
title: "Accumulo 4.0 Feature Preview"
author: Dave Marion
---

## Background

In version 2.1, we introduced two new optional and experimental features, [External Compactions](https://accumulo.apache.org/blog/2021/07/08/external-compactions.html) and [ScanServers](https://github.com/apache/accumulo/pull/2665). The External Compactions feature included two new server processes, the CompactionCoordinator and the Compactor. Using these new processes and their related configurations allows the user to perform major compactions on Tablets external to the TabletServer process. The configuration in 2.1 allows the user to define different “queues” for the External Compactions and to assign a “queue” to the Compactor process when it’s started. This provides the user with some capability to define the resources for different classes of compactions (see the referenced blog post for examples). External Compactions may provide lower latency for major compactions because major compactions that run in the TabletServer may queue up when all of the major compaction threads are busy. 

The ScanServers feature included one new server process, the ScanServer, which allows users to execute scans against a Tablet external to the TabletServer. Because the ScanServer does not have access to the in-memory mutations within the TabletServer, we introduced a consistency level setting on the Scanner and BatchScanner where scans with the “immediate” consistency setting (default) would be sent to the TabletServer only and scans with the “eventual” consistency setting would be sent to a ScanServer. ScanServers can provide better allocation of resources against the current workload because many ScanServers can be used to scan the same Tablet, and a single ScanServer can be used to scan different versions of the Tablet. Immediate consistency scans are sent to the hosting TabletServer where they could possibly queue up, where eventual consistency scans can be serviced by many ScanServers at the cost of not seeing the most recent data (this time delta is configurable). ScanServer processes can be started with a group name which can be used in the client configuration such that eventual scans of a particular type can be sent to a specific group of ScanServer processes.

## New For 4.0

The features in version 4.0 are intended to make running Accumulo in a cloud environment more cost-efficient by building on the optional and experimental features added in version 2.1. Prior to version 4.0, running an Accumulo instance required enough compute resources to host enough TabletServers to support the ingest, query, and Tablet maintenance (compact, split, merge, etc.) workload as Accumulo was originally designed to keep all Tablets immediately accessible all the time. Version 4.0 allows the user more flexibility in how they deploy Accumulo server processes and how they interact with their data. Below we introduce the high-level features/changes included in version 4.0.

### On-Demand Tablets

On an upgrade to Accumulo 4.0, the upgrade code will assign all Tablets (except for the root and metadata tables) with an availability setting of ONDEMAND. What this means is that the Tablet is not assigned and hosted by a TabletServer by default. If an operation is performed that requires a Tablet to be hosted by a TabletServer, then the operation will wait for the Tablet to be assigned and hosted. This setting can be changed and checked using the Shell commands `setavailability` and `getavailability`, respectively. When a configurable amount of time has passed where the Tablet has been unused, then it will be unloaded. Other valid availability values are HOSTED, which means that the Tablet will always be hosted (the default in earlier versions of Accumulo), and UNHOSTED, which means that the Tablet will never be hosted. 

User operations that would require a Tablet to be hosted are live ingest and immediate consistency scans. Users can still interact with data in unhosted tablets via bulk import and eventual consistency scans, and users can still perform tablet maintenance operations on unhosted tablets. The root and metadata tables have an availability value of HOSTED, which cannot be changed by the user. If your application only performs eventual scans and bulk imports, then only one TabletServer is required with the sole purpose of hosting the root and metadata tables.

Because Tablets are now optionally hosted in a TabletServer, the implementation of all the Tablet maintenance functions had to be moved out of the TabletServer and re-implemented. Split, Merge, and other metadata-only operations were re-implemented as Fate operations in the Manager.

### External Compactions Only

If a Tablet is not hosted, and the user is bulk importing to it, this could trigger the need for a major compaction. Hosting the Tablet just for the purpose of compacting it will cause churn on the cluster as the balancer may move Tablets around. This led to the decision to move all major compactions to the External Compactions feature. In 4.0, the CompactionCoordinator component was merged into the Manager process, so manually running the CompactionCoordinator process is no longer required. Running at least one Compactor is required to perform major compactions on the root and metadata tables.

### Resource Groups

In version 4.0 a new group property can be supplied to the Compactor, ScanServer, and TabletServer processes (this replaces the “queue” property mentioned previously for Compactors). If not specified, the default group is used. These properties allow the user to create groups of processes with the same name that can be used to host Tablets, execute major compactions, and perform eventual scans. For example, application A may have requirements that dictate the need for immediate access to Tablet data and application B may have requirements that do not require immediate access to data. You would not want to host Tablets for these applications’ tables in the same set of TabletServers as the loading and unloading of application B’s Tablets would cause churn when balancing. Instead, you would likely want to create two sets of TabletServers, groups appA and appB, where their respective tables can be hosted. The number of TabletServers in the appA group would likely be static, and the number of TabletServers in the appB group can scale as demand requires.

### Increased Visibility

Speaking of scaling, in version 4.0 we are emitting more metrics that can be used to determine when and how a resource needs to be scaled. The resource group and application name tags can be used to identify the group and type of resource that needs to be scaled. The metric name and value can be used to determine how the resource needs to be scaled. For example, if the value for metric `accumulo.compactor.queue.jobs.queued` is increasing, you likely need more Compactor resources. Likewise, if the value for metric `accumulo.tserver.compactions.minc.queued` or `accumulo.tserver.hold` is increasing, then you might need to start more TabletServers.

## Possible Deployment Scenarios

With the new features described above, many possible deployment scenarios are possible. We highlight a few of them below.

### Scenario 1

The diagram below depicts the simplest deployment where all tables operate within the default group of resources. There are no ScanServers, so only immediate scans are available. Tablets for all tables are assigned, hosted, and balanced within the same set of TabletServers. Major compactions for all tablets are executed within the same set of Compactors.

![Scenario1](/images/blog/202409_accumulo4/AccumuloDeployment1.png)

### Scenario 2

The diagram below depicts a slightly more complicated deployment where ScanServers are also being used to support eventual scans against Tablets.

![Scenario2](/images/blog/202409_accumulo4/AccumuloDeployment2.png)

### Scenario 3

The diagram below depicts a deployment where multiple compactor groups are configured in the default resource group. The compaction configuration enables the user, for example, to send compactions to different groups based on the sum of the input file sizes. In this example we have two additional Compactor groups, default-small and default-large, that can be configured for some user tables. The Compactor group in the default resource group would be used for all other tables.  See the [RatioBasedCompactionPlanner](https://github.com/apache/accumulo/blob/main/core/src/main/java/org/apache/accumulo/core/spi/compaction/RatioBasedCompactionPlanner.java) for more information.

![Scenario3](/images/blog/202409_accumulo4/AccumuloDeployment3.png)

### Scenario 4

The diagram below depicts a scenario where a second resource group, app1, has been created to service Tablets for Tables associated with a particular application. The application can perform eventual and immediate consistent scans, and performs live ingest into the Tables, so it needs both ScanServers and TabletServers. The user would configure their application to perform eventual scans using the instructions in the ScanServer blog post, configure major compactions to run in the app1 Compactor group using the instructions in the RatioBasedCompactionPlanner, and would configure the associated tables with the property table.custom.assignment.group=app1.

![Scenario4](/images/blog/202409_accumulo4/AccumuloDeployment4.png)

### Scenario 5

The diagram below is a slight modification to the prior scenario that shows the same app1 resource group, but without TabletServers. In this situation the associated application is only performing bulk imports and eventual scans on table data.

![Scenario5](/images/blog/202409_accumulo4/AccumuloDeployment5.png)

## Current State and Path Forward

Version 4.0.0-SNAPSHOT has been merged into the main branch. We have added over 100 new integration tests and all of the old and new tests are passing. We are planning on performing testing at increasing scales to determine what other architectural changes are needed. For example, we have discussed the possibility of needing to run multiple active Manager processes as the Manager is now responsible for performing more functions (CompactionCoordinator, more Fate operations, etc.).

