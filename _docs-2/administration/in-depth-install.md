---
title: In-depth Installation
category: administration
order: 1
---

This document provides detailed instructions for installing Accumulo. For basic
instructions, see the [quick start].

## Hardware

Because we are running essentially two or three systems simultaneously layered
across the cluster: HDFS, Accumulo and MapReduce, it is typical for hardware to
consist of 4 to 8 cores, and 8 to 32 GB RAM. This is so each running process can have
at least one core and 2 - 4 GB each.

One core running HDFS can typically keep 2 to 4 disks busy, so each machine may
typically have as little as 2 x 300GB disks and as much as 4 x 1TB or 2TB disks.

It is possible to do with less than this, such as with 1u servers with 2 cores and 4GB
each, but in this case it is recommended to only run up to two processes per
machine -- i.e. DataNode and TabletServer or DataNode and MapReduce worker but
not all three. The constraint here is having enough available heap space for all the
processes on a machine.

## Network

Accumulo communicates via remote procedure calls over TCP/IP for both passing
data and control messages. In addition, Accumulo uses HDFS clients to
communicate with HDFS. To achieve good ingest and query performance, sufficient
network bandwidth must be available between any two machines.

In addition to needing access to ports associated with HDFS and ZooKeeper, Accumulo will
use the following default ports. Please make sure that they are open, or change
their value in [accumulo.properties].

|Port | Description | Property Name
|-----|-------------|--------------
|4445 | Shutdown Port (Accumulo MiniCluster) | n/a
|4560 | Accumulo monitor (for centralized log display) | [monitor.port.log4j]
|9995 | Accumulo HTTP monitor | [monitor.port.client]
|9997 | Tablet Server | [tserver.port.client]
|9998 | Accumulo GC | [gc.port.client]
|9999 | Master Server | [master.port.client]
|12234 | Accumulo Tracer | [trace.port.client]
|42424 | Accumulo Proxy Server | n/a
|10001 | Master Replication service | [master.replication.coordinator.port]
|10002 | TabletServer Replication service | [replication.receipt.service.port]

In addition, the user can provide `0` and an ephemeral port will be chosen instead. This
ephemeral port is likely to be unique and not already bound. Thus, configuring ports to
use `0` instead of an explicit value, should, in most cases, work around any issues of
running multiple distinct Accumulo instances (or any other process which tries to use the
same default ports) on the same hardware. Finally, the `*.port.client` properties will work
with the port range syntax (M-N) allowing the user to specify a range of ports for the
service to attempt to bind. The ports in the range will be tried in a 1-up manner starting
at the low end of the range to, and including, the high end of the range.

## Download Tarball

Download a binary distribution of Accumulo and install it to a directory on a disk with
sufficient space:

    cd <install directory>
    tar xzf accumulo-{{ page.latest_release }}-bin.tar.gz
    cd accumulo-{{ page.latest_release }}

Repeat this step on each machine in your cluster. Typically, the same `<install directory>`
is chosen for all machines in the cluster.

There are four scripts in the `bin/` directory that are used to manage Accumulo:

1. `accumulo` - Runs Accumulo command-line tools and starts Accumulo processes
2. `accumulo-service` - Runs Accumulo processes as services
3. `accumulo-cluster` - Manages Accumulo cluster on a single node or several nodes
4. `accumulo-util` - Accumulo utilities for creating configuration, native libraries, etc.

These scripts will be used in the remaining instructions to configure and run Accumulo.

## Dependencies

Accumulo requires HDFS and ZooKeeper to be configured and running
before starting. Password-less SSH should be configured between at least the
Accumulo master and TabletServer machines. It is also a good idea to run Network
Time Protocol (NTP) within the cluster to ensure nodes' clocks don't get too out of
sync, which can cause problems with automatically timestamped data.

## Configuration

The Accumulo tarball contains a `conf/` directory where Accumulo looks for configuration. If you
installed Accumulo using downstream packaging, the `conf/` could be something else like
`/etc/accumulo/`.

Before starting Accumulo, the configuration files [accumulo-env.sh] and [accumulo.properties] must
exist in `conf/` and be properly configured. If you are using `accumulo-cluster` to launch a
cluster, the `conf/` directory must also contain host files for Accumulo services (i.e [gc],
[masters], [monitor][monitor-host], [tservers], [tracers]). You can either create these files
manually or run `accumulo-cluster create-config`.

Logging is configured in [accumulo-env.sh] to use three log4j configuration files in `conf/`. The
file used depends on the Accumulo command or service being run. Logging for most Accumulo services
(i.e Master, TabletServer, Garbage Collector) is configured by [log4j-service.properties] except for
the Monitor which is configured by [log4j-monitor.properties]. All Accumulo commands (i.e `init`,
`shell`, etc) are configured by [log4j.properties].

### Configure accumulo-env.sh

Accumulo needs to know where to find the software it depends on. Edit [accumulo-env.sh]
and specify the following:

1. Enter the location of Hadoop for `$HADOOP_HOME`
2. Enter the location of ZooKeeper for `$ZOOKEEPER_HOME`
3. Optionally, choose a different location for Accumulo logs using `$ACCUMULO_LOG_DIR`

Accumulo uses `HADOOP_HOME` and `ZOOKEEPER_HOME` to locate Hadoop and Zookeeper jars
and add them the `CLASSPATH` variable. If you are running a vendor-specific release of Hadoop
or Zookeeper, you may need to change how your `CLASSPATH` is built in [accumulo-env.sh]. If
Accumulo has problems later on finding jars, run `accumulo classpath` to print Accumulo's
classpath.

You may want to change the default memory settings for Accumulo's TabletServer which are
by set in the `JAVA_OPTS` settings for 'tservers' in [accumulo-env.sh]. Note the
syntax is that of the Java JVM command line options. This value should be less than the
physical memory of the machines running TabletServers.

There are similar options for the master's memory usage and the garbage collector
process. Reduce these if they exceed the physical RAM of your hardware and
increase them, within the bounds of the physical RAM, if a process fails because of
insufficient memory.

Note that you will be specifying the Java heap space in [accumulo-env.sh]. You should
make sure that the total heap space used for the Accumulo tserver and the Hadoop
DataNode and TaskTracker is less than the available memory on each worker node in
the cluster. On large clusters, it is recommended that the Accumulo master, Hadoop
NameNode, secondary NameNode, and Hadoop JobTracker all be run on separate
machines to allow them to use more heap space. If you are running these on the
same machine on a small cluster, likewise make sure their heap space settings fit
within the available memory.

### Native Map

The tablet server uses a data structure called a MemTable to store sorted key/value
pairs in memory when they are first received from the client. When a minor compaction
occurs, this data structure is written to HDFS. The MemTable will default to using
memory in the JVM but a JNI version, called the native map, can be used to significantly
speed up performance by utilizing the memory space of the native operating system. The
native map also avoids the performance implications brought on by garbage collection
in the JVM by causing it to pause much less frequently.

#### Building

32-bit and 64-bit Linux and Mac OS X versions of the native map can be built by executing
`accumulo-util build-native`. If your system's default compiler options are insufficient,
you can add additional compiler options to the command line, such as options for the
architecture. These will be passed to the Makefile in the environment variable `USERFLAGS`.

Examples:

    accumulo-util build-native
    accumulo-util build-native -m32

After building the native map from the source, you will find the artifact in
`lib/native`. Upon starting up, the tablet server will look
in this directory for the map library. If the file is renamed or moved from its
target directory, the tablet server may not be able to find it. The system can
also locate the native maps shared library by setting `LD_LIBRARY_PATH`
(or `DYLD_LIBRARY_PATH` on Mac OS X) in [accumulo-env.sh].

#### Native Maps Configuration

As mentioned, Accumulo will use the native libraries if they are found in the expected
location and [tserver.memory.maps.native.enabled] is set to `true` (which is the default).
Using the native maps over JVM Maps nets a noticeable improvement in ingest rates; however,
certain configuration variables are important to modify when increasing the size of the
native map.

To adjust the size of the native map, modify the value of [tserver.memory.maps.max]. When increasing
this value, it is also important to adjust the values below:

* [table.compaction.minor.logs.threshold] - maximum number of write-ahead log files that a tablet
  can reference before they will be automatically minor compacted
* [tserver.walog.max.size] - maximum size of a write-ahead log.

The maximum size of the native maps for a server should be less than the product of the write-ahead
log maximum size and minor compaction threshold for log files:

    $table.compaction.minor.logs.threshold * $tserver.walog.max.size >= $tserver.memory.maps.max

This formula ensures that minor compactions won't be automatically triggered before the native
maps can be completely saturated.

Subsequently, when increasing the size of the write-ahead logs, it can also be important
to increase the HDFS block size that Accumulo uses when creating the files for the write-ahead log.
This is controlled via [tserver.wal.blocksize]. A basic recommendation is that when
[tserver.walog.max.size] is larger than 2GB in size, set [tserver.wal.blocksize] to 2GB.
Increasing the block size to a value larger than 2GB can result in decreased write
performance to the write-ahead log file which will slow ingest.

### Cluster Specification

If you are using `accumulo-cluster` to start a cluster, configure the following on the
machine that will serve as the Accumulo master:

1. Run `accumulo-cluster create-config` to create the [masters] and [tservers] files.
2. Write the IP address or domain name of the Accumulo Master to the [masters] file in `conf/`.
3. Write the IP addresses or domain name of the machines that will be TabletServers to the
   [tservers] file in `conf/`, one per line.

Note that if using domain names rather than IP addresses, DNS must be configured
properly for all machines participating in the cluster. DNS can be a confusing source
of errors.

### Configure accumulo.properties

Specify appropriate values for the following properties in [accumulo.properties]:

* [instance.zookeeper.host] - Enables Accumulo to find ZooKeeper. Accumulo uses ZooKeeper
  to coordinate settings between processes and helps finalize TabletServer failure.
* [instance.secret] - The instance needs a secret to enable secure communication between servers.
  Configure your secret and make sure that the [accumulo.properties] file is not readable to other
  users. For alternatives to storing the [instance.secret] in plaintext, please read the
  [Sensitive Configuration Values](#sensitive-configuration-values) section.

Some settings can be modified via the Accumulo shell and take effect immediately, but some settings
require a process restart to take effect. See the [configuration overview][config-mgmt]
documentation for details.

### Hostnames in configuration files

Accumulo has a number of configuration files which can contain references to other hosts in your
network. All of the "host" configuration files for Accumulo ([gc], [masters], [tservers],
[monitor][monitor-host], [tracers]) as well as [instance.volumes] in [accumulo.properties] must
contain some host reference.

While IP address, short hostnames, or fully qualified domain names (FQDN) are all technically valid,
it is good practice to always use FQDNs for both Accumulo and other processes in your Hadoop
cluster. Failing to consistently use FQDNs can have unexpected consequences in how Accumulo uses
the FileSystem.

A common way for this problem can be observed is via applications that use Bulk Ingest. The Accumulo
Master coordinates moving the input files to Bulk Ingest to an Accumulo-managed directory. However,
Accumulo cannot safely move files across different Hadoop FileSystems. This is problematic because
Accumulo also cannot make reliable assertions across what is the same FileSystem which is specified
with different names. Naively, while 127.0.0.1:8020 might be a valid identifier for an HDFS
instance, Accumulo identifies `localhost:8020` as a different HDFS instance than `127.0.0.1:8020`.

### Deploy Configuration

Copy [accumulo-env.sh] and [accumulo.properties] from the `conf/` directory on the master to all
Accumulo tablet servers. The "host" configuration files files `accumulo-cluster` only need to be on
servers where that command is run.

### Sensitive Configuration Values

Accumulo has a number of properties that can be specified via the [accumulo.properties]
file which are sensitive in nature, [instance.secret] and `trace.token.property.password`
are two common examples. Both of these properties, if compromised, have the ability
to result in data being leaked to users who should not have access to that data.

In Hadoop-2.6.0, a new CredentialProvider class was introduced which serves as a common
implementation to abstract away the storage and retrieval of passwords from plaintext
storage in configuration files. Any Property marked with the `Sensitive` annotation
is a candidate for use with these CredentialProviders. For version of Hadoop which lack
these classes, the feature will just be unavailable for use.

A comma separated list of CredentialProviders can be configured using the Accumulo Property
[general.security.credential.provider.paths]. Each configured URL will be consulted
when the Configuration object for [accumulo.properties] is accessed.

### Using a JavaKeyStoreCredentialProvider for storage

One of the implementations provided in Hadoop-2.6.0 is a Java KeyStore CredentialProvider.
Each entry in the KeyStore is the Accumulo Property key name. For example, to store the
[instance.secret], the following command can be used:

```
  hadoop credential create instance.secret --provider jceks://file/etc/accumulo/conf/accumulo.jceks
```

The command will then prompt you to enter the secret to use and create a keystore in:

```
  /path/to/accumulo/conf/accumulo.jceks
```

Then, [accumulo.properties] must be configured to use this KeyStore as a CredentialProvider:

```
general.security.credential.provider.paths=jceks://file/path/to/accumulo/conf/accumulo.jceks
```

This configuration will then transparently extract the [instance.secret] from
the configured KeyStore and alleviates a human readable storage of the sensitive
property.

A KeyStore can also be stored in HDFS, which will make the KeyStore readily available to
all Accumulo servers. If the local filesystem is used, be aware that each Accumulo server
will expect the KeyStore in the same location.

### Client Configuration

Accumulo clients are configured in a different way than Accumulo servers. [Accumulo clients
are created][accumulo-client] using Java builder methods or a [accumulo-client.properties]
file containing [client properties][client-props].

### Custom Table Tags

Accumulo has the ability for users to add custom tags to tables. This allows
applications to set application-level metadata about a table. These tags can be
anything from a table description, administrator notes, date created, etc.
This is done by naming and setting a property with a prefix {% plink table.custom.\* %}.

Currently, table properties are stored in ZooKeeper. This means that the number
and size of custom properties should be restricted on the order of 10's of properties
at most without any properties exceeding 1MB in size. ZooKeeper's performance can be
very sensitive to an excessive number of nodes and the sizes of the nodes. Applications
which leverage the user of custom properties should take these warnings into
consideration. There is no enforcement of these warnings via the API.

### Configuring the ClassLoader

Accumulo builds its Java classpath in [accumulo-env.sh]. This classpath can be viewed by running
`accumulo classpath`.

After an Accumulo application has started, it will load classes from the locations specified in the
deprecated [general.classpaths] property. Additionally, Accumulo will load classes from the
locations specified in the [general.dynamic.classpaths] property and will monitor and reload them if
they change. The reloading feature is useful during the development and testing of iterators as new
or modified iterator classes can be deployed to Accumulo without having to restart the database.

Accumulo also has an alternate configuration for the classloader which will allow it to load classes
from remote locations. This mechanism uses Apache Commons VFS which enables locations such as http
and hdfs to be used. This alternate configuration also uses the [general.classpaths] property in the
same manner described above. It differs in that you need to configure the [general.vfs.classpaths]
property instead of the [general.dynamic.classpaths] property. As in the default configuration, this
alternate configuration will also monitor the vfs locations for changes and reload if necessary.

##### ClassLoader Contexts

With the addition of the VFS based classloader, we introduced the notion of classloader contexts. A
context is identified by a name and references a set of locations from which to load classes and can
be specified in the [accumulo.properties] file or added using the `config` command in the shell.
Below is an example for specify the app1 context in the [accumulo.properties] file:

```
# Application A classpath, loads jars from HDFS and local file system
general.vfs.context.classpath.app1=hdfs://localhost:8020/applicationA/classpath/.*.jar,file:///opt/applicationA/lib/.*.jar
```

The default behavior follows the Java ClassLoader contract in that classes, if they exists, are
loaded from the parent classloader first. You can override this behavior by delegating to the parent
classloader after looking in this classloader first. An example of this configuration is:

```
general.vfs.context.classpath.app1.delegation=post
```

To use contexts in your application you can set the {% plink table.classpath.context %} on your
tables or use the `setClassLoaderContext()` method on Scanner and BatchScanner passing in the name
of the context, app1 in the example above. Setting the property on the table allows your minc, majc,
and scan iterators to load classes from the locations defined by the context. Passing the context
name to the scanners allows you to override the table setting to load only scan time iterators from
a different location.

## Initialization

Accumulo must be initialized to create the structures it uses internally to locate
data across the cluster. HDFS is required to be configured and running before
Accumulo can be initialized.

Once HDFS is started, initialization can be performed by executing `accumulo init`. This script will
prompt for a name for this instance of Accumulo. The instance name is used to identify a set of
tables and instance-specific settings. The script will then write some information into HDFS so
Accumulo can start properly.

The initialization script will prompt you to set a root password. Once Accumulo is initialized it
can be started.

## Running

### Starting Accumulo

Make sure Hadoop is configured on all of the machines in the cluster, including access to a shared
HDFS instance. Make sure HDFS and ZooKeeper are running. Make sure ZooKeeper is configured and
running on at least one machine in the cluster. Start Accumulo using `accumulo-cluster start`.

To verify that Accumulo is running, check the [Accumulo monitor][monitor]. In addition, the Shell
can provide some information about the status of tables via reading the metadata tables.

### Stopping Accumulo

To shutdown cleanly, run `accumulo-cluster stop` and the master will orchestrate the
shutdown of all the tablet servers. Shutdown waits for all minor compactions to finish, so it may
take some time for particular configurations.

### Adding a Tablet Server

Update your `conf/tservers` file to account for the addition.

Next, ssh to each of the hosts you want to add and run:

    accumulo-service tserver start

Make sure the host in question has the new configuration, or else the tablet
server won't start; at a minimum this needs to be on the host(s) being added,
but in practice it's good to ensure consistent configuration across all nodes.

### Decommissioning a Tablet Server

If you need to take a node out of operation, you can trigger a graceful shutdown of a tablet
server. Accumulo will automatically rebalance the tablets across the available tablet servers.

    accumulo admin stop <host(s)> {<host> ...}

Alternatively, you can ssh to each of the hosts you want to remove and run:

    accumulo-service tserver stop

Be sure to update your `conf/tservers` file to account for the removal of these hosts. Bear in mind
that the monitor will not re-read the tservers file automatically, so it will report the
decommissioned servers as down; it's recommended that you restart the monitor so that the node list
is up to date.

The steps described to decommission a node can also be used (without removal of the host from the
`conf/tservers` file) to gracefully stop a node. This will ensure that the tabletserver is cleanly
stopped and recovery will not need to be performed when the tablets are re-hosted.

### Restarting process on a node

Occasionally, it might be necessary to restart the processes on a specific node. In addition
to the `accumulo-cluster` script, Accumulo has a `accumulo-service` script that
can be use to start/stop processes on a node.

#### A note on rolling restarts

For sufficiently large Accumulo clusters, restarting multiple TabletServers within a short window
can place significant load on the Master server. If slightly lower availability is acceptable, this
load can be reduced by globally setting [table.suspend.duration] to a positive value.

With [table.suspend.duration] set to, say, `5m`, Accumulo will wait for 5 minutes for any dead
TabletServer to return before reassigning that TabletServer's responsibilities to other
TabletServers. If the TabletServer returns to the cluster before the specified timeout has elapsed,
Accumulo will assign the TabletServer its original responsibilities.

It is important not to choose too large a value for [table.suspend.duration], as during this time,
all scans against the data that TabletServer had hosted will block (or time out).

### Running multiple TabletServers on a single node

With very powerful nodes, it may be beneficial to run more than one TabletServer on a given
node. This decision should be made carefully and with much deliberation as Accumulo is designed
to be able to scale to using 10's of GB of RAM and 10's of CPU cores.

Accumulo TabletServers bind certain ports on the host to accommodate remote procedure calls to/from
other nodes. Running more than one TabletServer on a host requires that you set the environment
variable `ACCUMULO_SERVICE_INSTANCE` to an instance number (i.e 1, 2) for each instance that is
started. Also, set the these properties in [accumulo.properties]:

* {% plink tserver.port.search %} = `true`
* {% plink replication.receipt.service.port %} = `0`

In order to start multiple TabletServers on a node, the `accumulo` command must be used:

```
ACCUMULO_SERVICE_INSTANCE=1 ./bin/accumulo tserver &> ./logs/tserver1.out &
ACCUMULO_SERVICE_INSTANCE=2 ./bin/accumulo tserver &> ./logs/tserver2.out &
```

#### Running multiple TabletServers per node in Accumulo 2.1.0 and later
Starting with Accumulo 2.1.0, the `accumulo-cluster` script can be used along with environment
variable `NUM_TSERVERS` as a convenient alternative to the `accumulo` command to start / stop
multiple TabletServers per node. For example, the following commands can be used to start / stop
2 TabletServers on the current node:

```
NUM_TSERVERS=2 ./bin/accumulo-cluster start-here
NUM_TSERVERS=2 ./bin/accumulo-cluster stop-here
```

To start / stop the entire Accumulo cluster with 2 TabletServers per worker node, use:

```
NUM_TSERVERS=2 ./bin/accumulo-cluster start
NUM_TSERVERS=2 ./bin/accumulo-cluster stop
```

Other commands like `accumulo-cluster start-tservers` and `accumulo-cluster stop-tservers` support
the use of `NUM_TSERVERS` to specify the number of TabletServers per worker node.

When `accumulo-cluster` is used along with `NUM_TSERVERS` greater than 1, the resultant log files
and redirected stdout / stderr files for each TabletServer running on the node have the instance
number as part of their respective filenames.

Lastly, starting with Accumulo 2.1.0 the `accumulo-env.sh` script ensures that Accumulo metrics
are correctly associated with the respective instance number for each TabletServer on a node.

## Logging

Accumulo processes each write to a set of log files. By default, these logs are found at directory
set by `ACCUMULO_LOG_DIR` in [accumulo-env.sh].

### Audit Logging

Accumulo logs many user-initiated actions, and whether they succeeded or failed, to an slf4j logger
named `org.apache.accumulo.audit`. This logger can be configured in the user's logging framework
(such as log4j or logback). In the tarball, the configuration file `conf/log4j-service.properties`
demonstrates basic audit logging with example configuration options for log4j.

## Recovery

In the event of TabletServer failure or error on shutting Accumulo down, some
mutations may not have been minor compacted to HDFS properly. In this case,
Accumulo will automatically reapply such mutations from the write-ahead log
either when the tablets from the failed server are reassigned by the Master (in the
case of a single TabletServer failure) or the next time Accumulo starts (in the event of
failure during shutdown).

Recovery is performed by asking a tablet server to sort the logs so that tablets can easily find
their missing updates. The sort status of each file is displayed on Accumulo monitor status page.
Once the recovery is complete any tablets involved should return to an `online` state. Until then
those tablets will be unavailable to clients.

The Accumulo client library is configured to retry failed mutations and in many
cases clients will be able to continue processing after the recovery process without
throwing an exception.

## Migrating Accumulo from non-HA Namenode to HA Namenode

The following steps will allow a non-HA instance to be migrated to an HA instance. Consider an HDFS
URL `hdfs://namenode.example.com:8020` which is going to be moved to `hdfs://nameservice1`.

Before moving HDFS over to the HA namenode, use `accumulo admin volumes` to confirm
that the only volume displayed is the volume from the current namenode's HDFS URL.

    Listing volumes referenced in zookeeper
            Volume : hdfs://namenode.example.com:8020/accumulo

    Listing volumes referenced in accumulo.root tablets section
            Volume : hdfs://namenode.example.com:8020/accumulo
    Listing volumes referenced in accumulo.root deletes section (volume replacement occurs at deletion time)

    Listing volumes referenced in accumulo.metadata tablets section
            Volume : hdfs://namenode.example.com:8020/accumulo

    Listing volumes referenced in accumulo.metadata deletes section (volume replacement occurs at deletion time)

After verifying the current volume is correct, shut down the cluster and transition HDFS to the HA
nameservice.

Edit [accumulo.properties] to notify accumulo that a volume is being replaced. First, add the new
nameservice volume to the [instance.volumes] property. Next, add the [instance.volumes.replacements]
property in the form of `old new`. It's important to not include the volume that's being replaced in
[instance.volumes], otherwise it's possible accumulo could continue to write to the volume.

```
# instance.dfs.uri and instance.dfs.dir should not be set
instance.volumes=hdfs://nameservice1/accumulo
instance.volumes.replacements=hdfs://namenode.example.com:8020/accumulo hdfs://nameservice1/accumulo
```

Run `accumulo init --add-volumes` and start up the accumulo cluster. Verify that the
new nameservice volume shows up with `accumulo admin volumes`.

    Listing volumes referenced in zookeeper
            Volume : hdfs://namenode.example.com:8020/accumulo
            Volume : hdfs://nameservice1/accumulo

    Listing volumes referenced in accumulo.root tablets section
            Volume : hdfs://namenode.example.com:8020/accumulo
            Volume : hdfs://nameservice1/accumulo
    Listing volumes referenced in accumulo.root deletes section (volume replacement occurs at deletion time)

    Listing volumes referenced in accumulo.metadata tablets section
            Volume : hdfs://namenode.example.com:8020/accumulo
            Volume : hdfs://nameservice1/accumulo
    Listing volumes referenced in accumulo.metadata deletes section (volume replacement occurs at deletion time)

Some erroneous GarbageCollector messages may still be seen for a small period while data is
transitioning to the new volumes. This is expected and can usually be ignored.

## Achieving Stability in a VM Environment

For testing, demonstration, and even operation uses, Accumulo is often
installed and run in a virtual machine (VM) environment. The majority of
long-term operational uses of Accumulo are on bare-metal cluster. However, the
core design of Accumulo and its dependencies do not preclude running stably for
long periods within a VM. Many of Accumulo’s operational robustness features to
handle failures like periodic network partitioning in a large cluster carry
over well to VM environments. This guide covers general recommendations for
maximizing stability in a VM environment, including some of the common failure
modes that are more common when running in VMs.

### Known failure modes: Setup and Troubleshooting

In addition to the general failure modes of running Accumulo, VMs can introduce a
couple of environmental challenges that can affect process stability. Clock
drift is something that is more common in VMs, especially when VMs are
suspended and resumed. Clock drift can cause Accumulo servers to assume that
they have lost connectivity to the other Accumulo processes and/or lose their
locks in Zookeeper. VM environments also frequently have constrained resources,
such as CPU, RAM, network, and disk throughput and capacity. Accumulo generally
deals well with constrained resources from a stability perspective (optimizing
performance will require additional tuning, which is not covered in this
section), however there are some limits.

#### Physical Memory

One of those limits has to do with the Linux out of memory killer. A common
failure mode in VM environments (and in some bare metal installations) is when
the Linux out of memory killer decides to kill processes in order to avoid a
kernel panic when provisioning a memory page. This often happens in VMs due to
the large number of processes that must run in a small memory footprint. In
addition to the Linux core processes, a single-node Accumulo setup requires a
Hadoop Namenode, a Hadoop Secondary Namenode a Hadoop Datanode, a Zookeeper
server, an Accumulo Master, an Accumulo GC and an Accumulo TabletServer.
Typical setups also include an Accumulo Monitor, an Accumulo Tracer, a Hadoop
ResourceManager, a Hadoop NodeManager, provisioning software, and client
applications. Between all of these processes, it is not uncommon to
over-subscribe the available RAM in a VM. We recommend setting up VMs without
swap enabled, so rather than performance grinding to a halt when physical
memory is exhausted the kernel will randomly select processes to kill in order
to free up memory.

Calculating the maximum possible memory usage is essential in creating a stable
Accumulo VM setup. Safely engineering memory allocation for stability is a
matter of then bringing the calculated maximum memory usage under the physical
memory by a healthy margin. The margin is to account for operating system-level
operations, such as managing process, maintaining virtual memory pages, and
file system caching. When the java out-of-memory killer finds your process, you
will probably only see evidence of that in /var/log/messages. Out-of-memory
process kills do not show up in Accumulo or Hadoop logs.

To calculate the max memory usage of all java virtual machine (JVM) processes
add the maximum heap size (often limited by a -Xmx... argument, such as in
accumulo.properties) and the off-heap memory usage. Off-heap memory usage
includes the following:

* "Permanent Space", where the JVM stores Classes, Methods, and other code elements. This can be
  limited by a JVM flag such as `-XX:MaxPermSize:100m`, and is typically tens of megabytes.
* Code generation space, where the JVM stores just-in-time compiled code. This is typically small
  enough to ignore
* Socket buffers, where the JVM stores send and receive buffers for each socket.
* Thread stacks, where the JVM allocates memory to manage each thread.
* Direct memory space and JNI code, where applications can allocate memory outside of the
  JVM-managed space. For Accumulo, this includes the native in-memory maps that are allocated with
  the memory.maps.max parameter in accumulo.properties.
* Garbage collection space, where the JVM stores information used for garbage collection.

You can assume that each Hadoop and Accumulo process will use ~100-150MB for
Off-heap memory, plus the in-memory map of the Accumulo TServer process. A
simple calculation for physical memory requirements follows:

```
  Physical memory needed
    = (per-process off-heap memory) + (heap memory) + (other processes) + (margin)
    = (number of java processes * 150M + native map) + (sum of -Xmx settings for java process)
        + (total applications memory, provisioning memory, etc.) + (1G)
    = (11*150M +500M) + (1G +1G +1G +256M +1G +256M +512M +512M +512M +512M +512M) + (2G) + (1G)
    = (2150M) + (7G) + (2G) + (1G)
    = ~12GB
```

These calculations can add up quickly with the large number of processes,
especially in constrained VM environments. To reduce the physical memory
requirements, it is a good idea to reduce maximum heap limits and turn off
unnecessary processes. If you're not using YARN in your application, you can
turn off the ResourceManager and NodeManager. If you're not expecting to
re-provision the cluster frequently you can turn off or reduce provisioning
processes such as Salt Stack minions and masters.

#### Disk Space

Disk space is primarily used for two operations: storing data and storing logs.
While Accumulo generally stores all of its key/value data in HDFS, Accumulo,
Hadoop, and Zookeeper all store a significant amount of logs in a directory on
a local file system. Care should be taken to make sure that (a) limitations to
the amount of logs generated are in place, and (b) enough space is available to
host the generated logs on the partitions that they are assigned. When space is
not available to log, processes will hang. This can cause interruptions in
availability of Accumulo, as well as cascade into failures of various
processes.

Hadoop, Accumulo, and Zookeeper use log4j as a logging mechanism, and each of
them has a way of limiting the logs and directing them to a particular
directory. Logs are generated independently for each process, so when
considering the total space you need to add up the maximum logs generated by
each process. Typically, a rolling log setup in which each process can generate
something like 10 100MB files is instituted, resulting in a maximum file system
usage of 1GB per process. Default setups for Hadoop and Zookeeper are often
unbounded, so it is important to set these limits in the logging configuration
files for each subsystem. Consult the user manual for each system for
instructions on how to limit generated logs.

#### Zookeeper Interaction

Accumulo is designed to scale up to thousands of nodes. At that scale,
intermittent interruptions in network service and other rare failures of
compute nodes become more common. To limit the impact of node failures on
overall service availability, Accumulo uses a heartbeat monitoring system that
leverages Zookeeper's ephemeral locks. There are several conditions that can
occur that cause Accumulo process to lose their Zookeeper locks, some of which
are true interruptions to availability and some of which are false positives.
Several of these conditions become more common in VM environments, where they
can be exacerbated by resource constraints and clock drift.

#### Tested Versions

Each release of Accumulo is built with a specific version of Apache
Hadoop, Apache ZooKeeper and Apache Thrift. We expect Accumulo to
work with versions that are API compatible with those versions.
However this compatibility is not guaranteed because Hadoop, ZooKeeper
and Thrift may not provide guarantees between their own versions. We
have also found that certain versions of Accumulo and Hadoop included
bugs that greatly affected overall stability. Thrift is particularly
prone to compatibility changes between versions and you must use the
same version your Accumulo is built with.

Please check the release notes for your Accumulo version or use the
mailing lists at https://accumulo.apache.org for more info.

[quick start]: {% durl getting-started/quickstart %}
[monitor]: {% durl administration/monitoring-metrics#monitor %}
[config-mgmt]: {% durl configuration/overview %}
[instance.volumes]: {% purl instance.volumes %}
[instance.volumes.replacements]: {% purl instance.volumes.replacements %}
[instance.zookeeper.host]: {% purl instance.zookeeper.host %}
[instance.secret]: {% purl instance.secret %}
[monitor.port.log4j]: {% purl monitor.port.log4j %}
[monitor.port.client]: {% purl monitor.port.client %}
[tserver.port.client]: {% purl tserver.port.client %}
[gc.port.client]: {% purl gc.port.client %}
[master.port.client]: {% purl master.port.client %}
[trace.port.client]: {% purl trace.port.client %}
[table.suspend.duration]: {% purl table.suspend.duration %}
[master.replication.coordinator.port]: {% purl master.replication.coordinator.port %}
[replication.receipt.service.port]: {% purl replication.receipt.service.port %}
[tserver.memory.maps.native.enabled]: {% purl tserver.memory.maps.native.enabled %}
[tserver.memory.maps.max]: {% purl tserver.memory.maps.max %}
[table.compaction.minor.logs.threshold]: {% purl table.compaction.minor.logs.threshold %}
[tserver.walog.max.size]: {% purl tserver.walog.max.size %}
[tserver.wal.blocksize]: {% purl tserver.wal.blocksize %}
[general.security.credential.provider.paths]: {% purl general.security.credential.provider.paths %}
[general.classpaths]: {% purl general.classpaths %}
[general.dynamic.classpaths]: {% purl general.dynamic.classpaths %}
[general.vfs.classpaths]: {% purl general.vfs.classpaths %}
[accumulo-client]: {% durl getting-started/clients#creating-an-accumulo-client %}
[client-props]: {% durl configuration/client-properties %}
[accumulo-env.sh]: {% durl configuration/files#accumulo-envsh %}
[accumulo.properties]: {% durl configuration/files#accumuloproperties %}
[accumulo-client.properties]: {% durl configuration/files#accumulo-clientproperties %}
[gc]: {% durl configuration/files#gc %}
[master]: {% durl configuration/files#gc %}
[monitor-host]: {% durl configuration/files#monitor %}
[masters]: {% durl configuration/files#masters %}
[tservers]: {% durl configuration/files#tservers %}
[tracers]: {% durl configuration/files#tracers %}
[log4j-service.properties]: {% durl configuration/files#log4j-serviceproperties %}
[log4j-monitor.properties]: {% durl configuration/files#log4j-monitorproperties %}
[log4j.properties]: {% durl configuration/files#log4jproperties %}
