---
title: Basic Troubleshooting
category: troubleshooting
order: 1
---

## General

**The tablet server does not seem to be running!? What happened?**

Accumulo is a distributed system.  It is supposed to run on remote
equipment, across hundreds of computers.  Each program that runs on
these remote computers writes down events as they occur, into a local
file. By default, this is defined in `conf/accumulo-env.sh` as `ACCUMULO_LOG_DIR`.
Look in the `$ACCUMULO_LOG_DIR/tserver*.log` file.  Specifically, check the end of the file.

**The tablet server did not start and the debug log does not exists!  What happened?**

When the individual programs are started, the stdout and stderr output
of these programs are stored in `.out` and `.err` files in
`$ACCUMULO_LOG_DIR`.  Often, when there are missing configuration
options, files or permissions, messages will be left in these files.
Probably a start-up problem.  Look in `$ACCUMULO_LOG_DIR/tserver*.err`

**Accumulo is not working, what's wrong?**

There's a small web server that collects information about all the
components that make up a running Accumulo instance. It will highlight
unusual or unexpected conditions.

Point your browser to the monitor (typically the master host, on port 9995).  Is anything red or yellow?

**My browser is reporting connection refused, and I cannot get to the monitor**

The monitor program's output is also written to .err and .out files in
the `$ACCUMULO_LOG_DIR`. Look for problems in this file if the
`$ACCUMULO_LOG_DIR/monitor*.log` file does not exist.

The monitor program is probably not running.  Check the log files for errors.

**My browser hangs trying to talk to the monitor.**

Your browser needs to be able to reach the monitor program.  Often
large clusters are firewalled, or use a VPN for internal
communications. You can use SSH to proxy your browser to the cluster,
or consult with your system administrator to gain access to the server
from your browser.

It is sometimes helpful to use a text-only browser to sanity-check the
monitor while on the machine running the monitor:

    $ links http://localhost:9995

Verify that you are not firewalled from the monitor if it is running on a remote host.

**The monitor responds, but there are no numbers for tservers and tables.  The summary page says the master is down.**

The monitor program gathers all the details about the master and the
tablet servers through the master. It will be mostly blank if the
master is down. Check for a running master.

**The ZooKeeper information is not available on the Overview page.**

The monitor uses the ZooKeeper `stat` [four-letter-word][zk-4lw] command to retrieve information.
The ZooKeeper configuration may require explicitly listing the `stat` command in the four-letter-word whitelist.

## Accumulo Processes

**My tablet server crashed!  The logs say that it lost its zookeeper lock.**

Tablet servers reserve a lock in zookeeper to maintain their ownership
over the tablets that have been assigned to them.  Part of their
responsibility for keeping the lock is to send zookeeper a keep-alive
message periodically.  If the tablet server fails to send a message in
a timely fashion, zookeeper will remove the lock and notify the tablet
server.  If the tablet server does not receive a message from
zookeeper, it will assume its lock has been lost, too.  If a tablet
server loses its lock, it kills itself: everything assumes it is dead
already.

Investigate why the tablet server did not send a timely message to
zookeeper.

**I need to decommission a node.  How do I stop the tablet server on it?**

Use the admin command:

    $ accumulo admin stop hostname:9997
    2013-07-16 13:15:38,403 [util.Admin] INFO : Stopping server 12.34.56.78:9997

**I cannot login to a tablet server host, and the tablet server will not shut down.  How can I kill the server?**

Sometimes you can kill a "stuck" tablet server by deleting its lock in zookeeper:

    $ accumulo org.apache.accumulo.server.util.TabletServerLocks --list
                      127.0.0.1:9997 TSERV_CLIENT=127.0.0.1:9997
    $ accumulo org.apache.accumulo.server.util.TabletServerLocks -delete 127.0.0.1:9997
    $ accumulo org.apache.accumulo.server.util.TabletServerLocks -list
                      127.0.0.1:9997             null

You can find the master and instance id for any accumulo instances using the same zookeeper instance:

```
$ accumulo org.apache.accumulo.server.util.ListInstances
INFO : Using ZooKeepers localhost:2181

 Instance Name       | Instance ID                          | Master
---------------------+--------------------------------------+-------------------------------
              "test" | 6140b72e-edd8-4126-b2f5-e74a8bbe323b |                127.0.0.1:9999
```

**One of my Accumulo processes died. How do I bring it back?**

The easiest way to bring all services online for an Accumulo instance is to run the `accumulo-cluster` script.

    $ accumulo-cluster start

This process will check the process listing, using `jps` on each host before attempting to restart a service on the given host.
Typically, this check is sufficient except in the face of a hung/zombie process. For large clusters, it may be
undesirable to ssh to every node in the cluster to ensure that all hosts are running the appropriate processes and `accumulo-service` may be of use.

    $ ssh host_with_dead_process
    $ accumulo-service tserver start

**My process died again. Should I restart it via `cron` or tools like `supervisord`?**

A repeatedly dying Accumulo process is a sign of a larger problem. Typically these problems are due to a
misconfiguration of Accumulo or over-saturation of resources. Blind automation of any service restart inside of Accumulo
is generally an undesirable situation as it is indicative of a problem that is being masked and ignored. Accumulo
processes should be stable on the order of months and not require frequent restart.

## Accumulo Clients

**Accumulo is not showing me any data!**

Is your client configured with authorizations that match your visibilities?  See the
[Authorizations documentation]({% durl security/authorizations %}) for help.

**What are my visibilities?**

Use the [rfile-info] tool on a representative file to get some idea
of the visibilities in the underlying data.

Note that the use of `rfile-info` is an administrative tool and can only
by used by someone who can access the underlying Accumulo data. It
does not provide the normal access controls in Accumulo.

## Ingest

**Why does my ingest rate periodically go down during heavy ingest?**

Periods of zero or low ingest rates can be caused by Java garbage collection pauses in tablet servers. This problem
can be mitigated by [enabling native maps in tablet servers][native-maps].

## HDFS

Accumulo reads and writes to the Hadoop Distributed File System.
Accumulo needs this file system available at all times for normal operations.

**Accumulo is having problems "getting a block blk_1234567890123". How do I fix it?**

This troubleshooting guide does not cover HDFS, but in general, you
want to make sure that all the datanodes are running and an fsck check
finds the file system clean:

    $ hadoop fsck /accumulo

You can use:

    $ hadoop fsck /accumulo/path/to/corrupt/file -locations -blocks -files

to locate the block references of individual corrupt files and use those
references to search the name node and individual data node logs to determine which
servers those blocks have been assigned and then try to fix any underlying file
system issues on those nodes.

On a larger cluster, you may need to increase the number of Xcievers for HDFS DataNodes:

```xml
<property>
    <name>dfs.datanode.max.xcievers</name>
    <value>4096</value>
</property>
```

Verify HDFS is healthy, check the datanode logs.

## Zookeeper

**The `accumulo init` command is hanging. It says something about talking to zookeeper.**

Zookeeper is also a distributed service.  You will need to ensure that
it is up.  You can run the zookeeper command line tool to connect to
any one of the zookeeper servers:

    $ zkCli.sh -server zoohost
    ...
    [zk: zoohost:2181(CONNECTED) 0]

It is important to see the word `CONNECTED`!  If you only see
`CONNECTING` you will need to diagnose zookeeper errors.

Check to make sure that zookeeper is up, and that
`accumulo.properties` has been pointed to
your zookeeper server(s).

**Zookeeper is running, but it does not say CONNECTED**

Zookeeper processes talk to each other to elect a leader.  All updates
go through the leader and propagate to a majority of all the other
nodes.  If a majority of the nodes cannot be reached, zookeeper will
not allow updates.  Zookeeper also limits the number connections to a
server from any other single host.  By default, this limit can be as small as 10
and can be reached in some everything-on-one-machine test configurations.

You can check the election status and connection status of clients by
asking the zookeeper nodes for their status.  You connect to zookeeper
and ask it with the four-letter `stat` command:

```
$ nc zoohost 2181
stat
Zookeeper version: 3.4.5-1392090, built on 09/30/2012 17:52 GMT
Clients:
 /127.0.0.1:58289[0](queued=0,recved=1,sent=0)
 /127.0.0.1:60231[1](queued=0,recved=53910,sent=53915)

Latency min/avg/max: 0/5/3008
Received: 1561459
Sent: 1561592
Connections: 2
Outstanding: 0
Zxid: 0x621a3b
Mode: standalone
Node count: 22524
```

Check zookeeper status, verify that it has a quorum, and has not exceeded maxClientCnxns.

[rfile-info]: {% durl troubleshooting/tools#RFileInfo %}
[native-maps]: {% durl administration/in-depth-install#native-map %}
[zk-4lw]: https://zookeeper.apache.org/doc/r3.5.7/zookeeperAdmin.html#sc_4lw
