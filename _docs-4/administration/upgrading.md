---
title: Upgrading Accumulo
category: administration
order: 7
---

## Upgrading from 1.10 or 2.0 to 2.1

Please read these directions in their entirety before beginning. Please [contact] us with any
questions you have about this process.

**IMPORTANT!** Before running any Accumulo 2.1 upgrade utilities or services, you will need to
upgrade to Java 11, Hadoop 3, and at least ZooKeeper 3.5 (at least 3.8 was current at the time of
this writing and is recommended).

The basic upgrade sequence is:

- upgrade to at least Accumulo 1.10 first (if necessary)
- stop Accumulo 1.10 or 2.0
- prepare your installation of Accumulo 2.1 through whatever means you obtain the binaries and
  configure it in your environment
- start ZooKeeper and HDFS.
- (optional - but recommended) create a ZooKeeper snapshot
- (optional - but recommended) validate the ZooKeeper ACLs. See [ZooKeeper ACLs]({% durl troubleshooting/zookeeper#zookeeper-acls %})
- (required if not using the provided scripts to start 2.1) run the `RenameMasterDirInZK` utility
- (optional) run the pre-upgrade utility to convert the configuration in ZooKeeper
- start Accumulo 2.1 for the first time to complete the upgrade

**IMPORTANT!** before starting any upgrade process you need to make sure there are no outstanding
FATE transactions. This includes transactions that have completed with `SUCCESS` or `FAILED` but
have not been removed by the automatic clean-up process. This is required because the internal
serialization of FATE transactions is not guaranteed to be compatible between versions, so *ANY*
FATE transaction that is present will fail the upgrade. Procedures to manage FATE transactions,
including commands to fail and delete transactions, are included in the [FATE Administration
documentation]({% durl administration/fate#administration %}).

Two significant changes occurred in 2.1 that are particularly important to note for upgrades:

1. properties and services that referenced `master` are renamed `manager` and
2. the internal property storage format in ZooKeeper has changed - instead of each table, namespace,
   and the system configuration using separate ZooKeeper nodes for each of their properties, they
   each now use only a single ZooKeeper node for all of their respective properties.

Details on renaming the properties and the ZooKeeper property conversion are provided in the
following sections. Additional information on configuring 2.1 is [available here]({% durl
administration/in-depth-install %}).

### Create ZooKeeper snapshot (optional - but recommended)

Before upgrading to 2.1, it is suggested that you create a snapshot of the current ZooKeeper
contents to be a backup in case issues occur and you need to rollback. There are no provisions to
roll back to a previous Accumulo version once an upgrade process has been completed other than
restoring from a snapshot of ZooKeeper.

```
$ACCUMULO_HOME/bin/accumulo dump-zoo --xml --root /accumulo | tee PATH_TO_SNAPSHOT
```

If you need to restore from the ZooKeeper snapshot see [these instructions]({% durl
troubleshooting/tools#restorezookeeper %}).

### Rename master Properties, Config Files, and Script References

It is strongly recommended as a part of the upgrade to rename any properties in
`accumulo.properties` (or properties specified on the command line) starting with `master.` to use
the equivalent property starting with `manager.` instead, as the old properties will not be
available in subsequent major releases. This version may log or display warnings if older properties
are observed.

Any reference to `master` in other scripts (e.g., invoking `accumulo-service master` from an init
script) should be renamed to `manager` (for example, `accumulo-service manager`).

If the manager is not started using the provided `accumulo-cluster` or `accumulo-service` scripts,
then a one-time upgrade step will need to be performed. Run the `RenameMasterDirInZK` utility after
installing 2.1 but before starting it.

```
${ACCUMULO_HOME}/bin/accumulo org.apache.accumulo.manager.upgrade.RenameMasterDirInZK
```

### Pre-Upgrade the property storage in ZooKeeper (optional)

As mentioned above, the property storage in ZooKeeper has changed from many nodes per table,
namespace, and the system configuration, to just a single node for each of those. Upgrading to use
the new format does happen automatically when Accumulo 2.1 servers start up. However, you can
optionally choose to convert them using a pre-upgrade step with the following command line utility.

The property conversion can be done using a command line utility or it will occur automatically when
the manager is started for the first time. Using the command line utility is optional, but may
provide more flexibility in handling issues if they were to occur. With ZooKeeper running, the
command to convert the properties is:

```
$ACCUMULO_HOME/bin/accumulo config-upgrade
```

The utility will print messages about its progress as it converts them.

```
2022-11-03T14:35:44,596 [conf.SiteConfiguration] INFO : Found Accumulo configuration on classpath at /opt/fluo-uno/install/accumulo-3.0.0-SNAPSHOT/conf/accumulo.properties
2022-11-03T14:35:45,511 [util.ConfigPropertyUpgrader] INFO : Upgrade system config properties for a1518a8b-f007-41ee-af2c-5cc760abe7fd
2022-11-03T14:35:45,675 [util.ConfigTransformer] INFO : property transform for SystemPropKey{InstanceId=a1518a8b-f007-41ee-af2c-5cc760abe7fd'} took 29ms ms, delete count: 1, error count: 0
2022-11-03T14:35:45,683 [util.ConfigPropertyUpgrader] INFO : Upgrading namespace +accumulo base path: /accumulo/a1518a8b-f007-41ee-af2c-5cc760abe7fd/namespaces/+accumulo/conf
...
2022-11-03T14:35:45,737 [util.ConfigPropertyUpgrader] INFO : Upgrading table !0 base path: /accumulo/a1518a8b-f007-41ee-af2c-5cc760abe7fd/tables/!0/conf
2022-11-03T14:35:45,813 [util.ConfigTransformer] INFO : property transform for TablePropKey{TableId=!0'} took 72ms ms, delete count: 26, error count: 0
...
```

If the upgrade utility is not used, similar messages will print to the server logs when 2.1 starts.

When the property conversion is complete, you can verify the configuration using the
[zoo-info-viewer]({% durl /troubleshooting/tools#zoo-info-viewer-new-in-21 %}) utility (new in 2.1)

```
$ACCUMULO_HOME/bin/accumulo zoo-info-viewer  --print-props
```

### Create new cluster configuration file

The `accumulo-cluster` script now uses a single file that defines the location of the managers,
tservers, etc. You can create this file using the command `accumulo-cluster create-config`. You will
then need to transfer the contents of the current individual files to this new consolidated file.

### Encrypted Instances

**Warning**: Upgrading a previously encrypted instance with the experimental encryption properties
is not supported as the implementation and properties have changed. You may be able to disable
encryption and compact your files without encryption, in order to upgrade. Encryption remains an
experimental feature, and may change between versions. It should be used with care. If you need
help, consider reaching out to our mailing list.

## Upgrading from 1.8/9/10 to 2.0

Follow the steps below to upgrade your Accumulo instance and client to 2.0.

### Upgrade Accumulo instance

**IMPORTANT!** Before upgrading to Accumulo 2.0, you will need to upgrade to Java 8 and Hadoop 3.x.

Upgrading to Accumulo 2.0 is done by stopping Accumulo 1.8/9 and starting Accumulo 2.0.

Before stopping Accumulo 1.8/9, install Accumulo 2.0 and configure it by following the [2.0 quick start]({% durl getting-started/quickstart %}).

There are several changes to scripts and configuration in 2.0 so be careful when using configuration or automated setup designed for 1.8/9.
Below are some changes in 2.0 that you should be aware of:
* `accumulo.properties` has replaced `accumulo-site.xml`. You can either convert `accumulo-site.xml` by hand
  from XML to properties or use the following Accumulo command.
  ```
  accumulo convert-config -x old/accumulo-site.xml -p new/accumulo.properties
  ```
* The following [server properties]({% durl configuration/server-properties %}) were deprecated for 2.0:
   * {% plink general.classpaths %}
   * {% plink tserver.metadata.readahead.concurrent.max %}
   * {% plink tserver.readahead.concurrent.max  %}
* `accumulo-client.properties` has replaced `client.conf`. The [client properties]({% durl configuration/client-properties %})
  in the new file are different so take care when customizing.
* `accumulo-cluster` script has replaced the `start-all.sh` & `stop-all.sh` scripts.
   - Default host files (i.e `masters`, `monitor`, `gc`) are no longer in `conf/` directory of tarball but can be created using `accumulo-cluster create-config`
   - Tablet server hosts must be listed in a `tservers` file instead of a `slaves` file. To minimize confusion, Accumulo will not start if the old `slaves` file is present.
* `accumulo-service` script can be used to start/stop Accumulo services (i.e master, tablet server, monitor) on a single node.
    - Can be used even if Accumulo was started using `accumulo-cluster` script.
* `accumulo-env.sh` constructs environment variables (such as `JAVA_OPTS` and `CLASSPATH`) used when running Accumulo processes
    - This file was used in Accumulo 1.x but has changed significantly for 2.0
    - Environment variables (such as `$cmd`, `$bin`, `$conf`) are set before `accumulo-env.sh` is loaded and can be used to customize environment.
    - The `JAVA_OPTS` variable is constructed in `accumulo-env.sh` to pass command line arguments to the `java` command that the starts Accumulo processes
      (i.e. `java $JAVA_OPTS main.class.for.$cmd`).
    - The `CLASSPATH` variable sets the Java classpath used when running Accumulo processes. It can be modified to upgrade dependencies or use vendor-specific
      distributions of Hadoop.
* Logging is configured in `accumulo-env.sh` for Accumulo processes. The following log4j configuration files in the `conf/` directory will be used if
  `accumulo-env.sh` is not modified. These files can be modified to turn on/off logging for Accumulo processes:
    - `log4j-service.properties` for all Accumulo services (except monitor)
    - `logj4-monitor.properties` for Accumulo monitor
    - `log4j.properties` for Accumulo clients and commands
* MapReduce jobs that read/write from Accumulo [must configure their dependencies differently]({% durl development/mapreduce#configure-dependencies-for-your-mapreduce-job %}).
* Run the command `accumulo shell` to access the shell using configuration in `conf/accumulo-client.properties`

When your Accumulo 2.0 installation is properly configured, stop Accumulo 1.8/9 and start Accumulo 2.0:

```
./accumulo-1.9.3/bin/stop-all.sh
./accumulo-2.0.1/bin/accumulo-cluster start
```
It is recommended that users test this upgrade on development or test clusters before attempting it on production clusters.

### Upgrade Accumulo clients

There several client API changes in 2.0. In most cases, new API was introduced and the old API was only deprecated. While it is recommended
that users start using the new API, the old API will continue to be supported through 2.x.

Below is a list of client API changes that users are required to make for 2.0:

* Update your pom.xml use Accumulo 2.0. Also, update any Hadoop & ZooKeeper dependencies in your pom.xml to match the versions running on your cluster.
  ```xml
  <dependency>
    <groupId>org.apache.accumulo</groupId>
    <artifactId>accumulo-core</artifactId>
    <version>2.0.1</version>
  </dependency>
  ```
* ClientConfiguration objects can no longer be created using `new ClientConfiguration()`.
   * Use `ClientConfiguration.create()` instead
* Some API deprecated in 1.x releases was dropped
* Aggregators have been removed

Below is a list of recommended client API changes:

* The API for [creating Accumulo clients]({% durl getting-started/clients#creating-an-accumulo-client %}) has changed in 2.0.
  * The old API using [ZooKeeperInstance], [Connector], [Instance], and [ClientConfiguration] has been deprecated.
  * [Connector] objects can be created from an [AccumuloClient] object using [Connector.from()]
* Accumulo's [MapReduce API]({% durl development/mapreduce %}) has changed in 2.0.
  * A new API has been introduced in the `org.apache.accumulo.hadoop` package of the `accumulo-hadoop-mapreduce` jar.
  * The old API in the `org.apache.accumulo.core.client` package of the `accumulo-core` has been deprecated and will
    eventually be removed.
  * For both the old and new API, you must [configure dependencies differently]({% durl development/mapreduce#configure-dependencies-for-your-mapreduce-job %})
    when creating your MapReduce job.

## Upgrading from 1.7 to 1.8

Upgrades from 1.7 to 1.8 are possible with little effort as no changes were made at the data layer and RPC changes were made in a backwards-compatible way. The recommended way is to stop Accumulo 1.7, perform the Accumulo upgrade to 1.8, and then start 1.8. Like previous versions, after 1.8 is started on a 1.7 instance, a one-time upgrade will happen by the Master which will prevent a downgrade back to 1.7. Upgrades are still one way. Upgrades from versions prior to 1.7 to 1.8 should follow the below path to 1.7 and then perform the upgrade to 1.8 – direct upgrades to 1.8 for versions other than 1.7 are untested.

Existing configuration files from 1.7 should be compared against the examples provided in 1.8. The 1.7 configuration files should all function with 1.8 code, but you will likely want to include changes found in the 1.8.0 release notes and these release notes for 1.8.1.

For upgrades from prior to 1.7, follow the upgrade instructions to 1.7 first.

## Upgrading from 1.7.x to 1.7.y

The recommended way to upgrade from a prior 1.7.x release is to stop Accumulo, upgrade to 1.7.y and then start 1.7.y.

When upgrading, there is a known issue if the upgrade fails due to outstanding [FATE] operations, see [ACCUMULO-4496] The workaround if this situation is encountered:

- Start tservers
- Start shell
- Run ```fate print``` to list all
- If completed, just delete with ```fate delete```
- Start masters once there are no more fate operations

If any of the FATE operations are not complete, you should rollback the upgrade and troubleshoot completing them with your prior version. When performing an upgrade between major versions, the upgrade is one-way, therefore it is important that you do not have any outstanding FATE operations before starting the upgrade.

## Upgrading from 1.6 to 1.7

Upgrades from 1.6 to 1.7 are possible with little effort as no changes were made at the data layer and RPC changes were made in a backwards-compatible way. The recommended way is to stop Accumulo 1.6, perform the Accumulo upgrade to 1.7, and then start 1.7. Like previous versions, after 1.7.0 is started on a 1.6 instance, a one-time upgrade will happen by the Master which will prevent a downgrade back to 1.6. Upgrades are still one way. Upgrades from versions prior to 1.6 to 1.7 should follow the below path to 1.6 and then perform the upgrade to 1.7 – direct upgrades to 1.7 for versions other than 1.6 are untested.

After upgrading to 1.7.0, users will notice the addition of a replication table in the accumulo namespace. This table is created and put offline to avoid any additional maintenance if the data-center replication feature is not in use.

Existing configuration files from 1.6 should be compared against the examples provided in 1.7. The 1.6 configuration files should all function with 1.7 code, but you will likely want to include a new file (hadoop-metrics2-accumulo.properties) to enable the new metrics subsystem. Read the section on Hadoop Metrics2 in the Administration chapter of the Accumulo User Manual.

For each of the other new features, new configuration properties exist to support the feature. Refer to the added sections in the User Manual for the feature for information on how to properly configure and use the new functionality.

## Upgrading from 1.5 to 1.6

This happens automatically the first time Accumulo 1.6 is started.

If your instance previously upgraded from 1.4 to 1.5, you must verify that your
1.5 instance has no outstanding local write ahead logs. You can do this by ensuring
either:

- All of your tables are online and the Monitor shows all tablets hosted
- The directory for write ahead logs (logger.dir.walog) from 1.4 has no files remaining
    on any tablet server / logger hosts

To upgrade from 1.5 to 1.6 you must:

- Verify that there are no outstanding FATE operations
    - Under 1.5 you can list what's in FATE by running
      ```$ACCUMULO_HOME/bin/accumulo org.apache.accumulo.server.fate.Admin print```
    - Note that operations in any state will prevent an upgrade. It is safe
      to delete operations with status SUCCESSFUL. For others, you should restart
      your 1.5 cluster and allow them to finish.
- Stop the 1.5 instance.
- Configure 1.6 to use the hdfs directory and zookeepers that 1.5 was using.
- Copy other 1.5 configuration options as needed.
-  Start Accumulo 1.6.

  The upgrade process must make changes to Accumulo's internal state in both ZooKeeper and
  the table metadata. This process may take some time if Tablet Servers have to go through
  recovery. During this time, the Monitor will claim that the Master is down and some
  services may send the Monitor log messages about failure to communicate with each other.
  These messages are safe to ignore. If you need detail on the upgrade's progress you should
  view the local logs on the Tablet Servers and active Master.

## Upgrading from 1.4 to 1.6

To upgrade from 1.4 to 1.6 you must perform a manual initial step.

Prior to upgrading you must:

- Verify that there are no outstanding FATE operations
  - Under 1.4 you can list what's in FATE by running ```$ACCUMULO_HOME/bin/accumulo org.apache.accumulo.server.fate.Admin print```
  - Note that operations in any state will prevent an upgrade. It is safe to delete operations with status SUCCESSFUL. For others,
      you should restart your 1.4 cluster and allow them to finish.
- Stop the 1.4 instance.
- Configure 1.6 to use the hdfs directory, walog directories, and zookeepers that 1.4 was using.
- Copy other 1.4 configuration options as needed.

Prior to starting the 1.6 instance you will need to run the LocalWALRecovery tool on each node that previously ran an instance of the Logger role.

```
$ACCUMULO_HOME/bin/accumulo org.apache.accumulo.tserver.log.LocalWALRecovery
```

The recovery tool will rewrite the 1.4 write ahead logs into a format that 1.6 can read. After this step has completed on all nodes, start the 1.6 cluster to continue the upgrade.

The upgrade process must make changes to Accumulo's internal state in both ZooKeeper and the table metadata. This process may take some time if Tablet Servers have to go through recovery. During this time, the Monitor will claim that the Master is down and some services may send the Monitor log messages about failure to communicate with each other. While the upgrade is in progress, the Garbage Collector may complain about invalid paths. The Master may also complain about failure to create the trace table because it already exists. These messages are safe to ignore. If other error messages occur, you should seek out support before continuing to use Accumulo. If you need detail on the upgrade's progress you should view the local logs on the Tablet Servers and active Master.

Note that the LocalWALRecovery tool does not delete the local files. Once you confirm that 1.6 is successfully running, you should delete these files on the local filesystem.

## Upgrading from 1.4 to 1.5

This happens automatically the first time Accumulo 1.5 is started.

- Stop the 1.4 instance.
- Configure 1.5 to use the hdfs directory, walog directories, and zookeepers
  that 1.4 was using.
- Copy other 1.4 configuration options as needed.
- Start Accumulo 1.5.

[FATE]: {{ site.baseurl }}/1.7/accumulo_user_manual.html#_fault_tolerant_executor_fate
[ACCUMULO-4496]: https://issues.apache.org/jira/browse/ACCUMULO-4496
[ZooKeeperInstance]: {% jurl org.apache.accumulo.core.client.ZooKeeperInstance %}
[Connector]: {% jurl org.apache.accumulo.core.client.Connector %}
[Instance]: {% jurl org.apache.accumulo.core.client.Instance %}
[ClientConfiguration]: {% jurl org.apache.accumulo.core.client.ClientConfiguration %}
[AccumuloClient]: {% jurl org.apache.accumulo.core.client.AccumuloClient %}
[Connector.from()]: {% jurl org.apache.accumulo.core.client.Connector#from-org.apache.accumulo.core.client.AccumuloClient- %}
[contact]: {{ site.baseurl }}/contact-us
