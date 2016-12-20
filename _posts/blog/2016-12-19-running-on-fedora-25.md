---
title: "Running Accumulo on Fedora 25"
author: Christopher Tubbs and Mike Miller
reviewers: Keith Turner, Mike Walch
---

Apache Accumulo has been available in [Fedora] since F20. Recently, the Fedora
packages have been updated to Accumulo version `1.6.6` and have made some
improvements to the default configuration and launch scripts to provide a good
out-of-box experience. This post will discuss the basic setup procedures for
running Accumulo in the latest version, `Fedora 25`.

## Prepare the system

**WARNING**: Before you start, be sure you've got plenty of free disk space.
Otherwise, you could run into this [bug] or see other problems.

These instructions will assume you're using Fedora 25, fully up-to-date (`sudo
dnf --refresh upgrade`).

### Install packages

Fedora provides a meta-package to install Accumulo and all of its dependencies.
It's a good idea to install the JDK, so you'll have access to the `jps`
command, and `tuned` for setting system performance tuning parameters from a
profile. It's also a good idea to ensure the optional hadoop native libraries
are installed, and you have a good editor (replace `vim` with your preferred
editor):

```bash
sudo dnf install accumulo java-1.8.0-openjdk-devel tuned vim hadoop-common-native
```

It is possible to install only a specific Accumulo service. For the single node
setup, almost everything is needed. For the multi-node setup, it might make
more sense to be selective about which you choose to install on each node (for
example, to only install `accumulo-tserver`).

### Set up tuned

(Optional) `tuned` can optimize your server settings, adjusting things like
your `vm.swappiness`. To set up `tuned`, do:

```bash
sudo systemctl start tuned.service     # start service
sudo tuned-adm profile network-latency # pick a good profile
sudo tuned-adm active                  # verify the selected profile
sudo systemctl enable tuned.service    # auto-start on reboots
```

### Set up ZooKeeper

You'll need to set up ZooKeeper, regardless of whether you'll be running a
single node or many. So, let's create its configuration file (the defaults are
fine):

```bash
sudo cp /etc/zookeeper/zoo_sample.cfg /etc/zookeeper/zoo.cfg
```

Now, let's start ZooKeeper (and set it to run on reboot):

```bash
sudo systemctl start zookeeper.service
sudo systemctl enable zookeeper.service
```

Note that the default port for ZooKeeper is `2181`. Remember the hostname of
the node where ZooKeeper is running, referred to as `<zk-dns-name>` later.

## Running a single node

### Configure Accumulo

To run on a single node, you don't need to run HDFS. Accumulo can use the local
filesystem as a volume instead. By default, it uses `/tmp/accumulo`. Let's
change that to something which will survive a reboot:

```bash
sudo vim /etc/accumulo/accumulo-site.xml
```

Change the value of the `instance.volumes` property from `file:///tmp/accumulo`
to `file:///var/tmp/accumulo` in the configuration file (or another preferred
location).

While you are editing the Accumulo configuration file, you should also change
the default `instance.secret` from `DEFAULT` to something else. You can also
change the credentials used by the `tracer` service now, too. If you use the
`root` user, you'll have to set its password to the same one you'll use later
when you initialize Accumulo. If you use another user name, you'll have to
create that user later.

### Configure Hadoop client

Hadoop's default local filesystem handler isn't very good at ensuring files are
written to disk when services are stopped. So, let's use a better filesystem
implementation for `file://` locations. This implementation may not be as
robust as a full HDFS instance, but it's more reliable than the default. Even
though you're not going to be running HDFS, the Hadoop client code used in
Accumulo can still be configured by modifying Hadoop's configuration file:

```bash
sudo vim /etc/hadoop/core-site.xml
```

Add a new property:

```xml
  <property>
    <name>fs.file.impl</name>
    <value>org.apache.hadoop.fs.RawLocalFileSystem</value>
  </property>
```

### Initialize Accumulo

Now, initialize Accumulo. You'll need to do this as the `accumulo` user,
because the Accumulo services run as the `accumulo` user. This user is created
automatically by the RPMs if it doesn't exist when the RPMs are installed. If
you already have a user and/or group by this name, it will probably not be a
problem, but be aware that this user will have permissions for the server
configuration files. To initialize Accumulo as a specific user, use `sudo -u`:

```bash
sudo -u accumulo accumulo init
```

As expected, this command will fail if ZooKeeper is not running, or if the
destination volume (`file:///var/tmp/accumulo`) already exists.

### Start Accumulo services

Now that Accumulo is initialized, you can start its services:

```bash
sudo systemctl start accumulo-{master,tserver,gc,tracer,monitor}.service
```

Enable the commands to start at boot:

```bash
sudo systemctl enable accumulo-{master,tserver,gc,tracer,monitor}.service
```

## Running multiple nodes

### Amazon EC2 setup

For a multi-node setup, the authors tested these instructions with a Fedora 25
Cloud AMI on Amazon EC2 with the following characteristics:

* `us-east-1` availability zone
* `ami-e5757bf2` (latest in `us-east-1` at time of writing)
* `HVM` virtualization type
* `gp2` disk type
* `64GB EBS` root volume (no additional storage)
* `m4.large` and `m4.xlarge` instance types (tested on both)
* `3` nodes

For this setup, you should have a name service configured properly. For
convenience, we used the EC2 provided internal DNS, with internal IP addresses.
Make sure the nodes can communicate with each other using these names. If
you're using EC2, this means making sure they are in the same security group,
and the security group has an inbound rule for "All traffic" with the source
set to itself (`sg-xxxxxxxx`).

The default user is `fedora` for the Fedora Cloud AMIs. For the best
experience, don't forget to make sure they are fully up-to-date (`sudo dnf
--refresh upgrade`).

### Configure and run Hadoop

Configuring HDFS is the primary difference between the single and multi-node
setup. For both Hadoop and Accumulo, you can edit the configuration files on
one machine, and copy them to the others.

Pick a server to be the NameNode and identify its DNS name,
(`<namenode-dns-name>`). Edit Hadoop's configuration to set the default
filesystem name to this location:

```bash
sudo vim /etc/hadoop/core-site.xml
```

Set the value for the property `fs.default.name` to
`hdfs://<namenode-dns-name>:8020`.

Distribute copies of the changed configuration files to each node.

Now, format the NameNode. You'll need to do this as the `hdfs` user on the
NameNode instance:

```bash
sudo -u hdfs hdfs namenode -format
```

On the NameNode, start the NameNode service and enable it on reboot:

```bash
sudo systemctl start hadoop-namenode.service
sudo systemctl enable hadoop-namenode.service
```

On each DataNode, start the DataNode service:

```bash
sudo systemctl start hadoop-datanode.service
sudo systemctl enable hadoop-datanode.service
```

### Configure and run Accumulo

Update Accumulo's configuration to use this HDFS filesystem:

```bash
sudo vim /etc/accumulo/accumulo-site.xml
```

Change the value of the `instance.volumes` to
`hdfs://<namenode-dns-name>:8020/accumulo` in the configuration file. Don't
forget to also change the default `instance.secret` and the trace user's
credentials, if necessary. Also, since you will have multiple nodes, you cannot
use `localhost:2181` for ZooKeeper, so set `instance.zookeeper.host` to
`<zk-dns-name>:2181`.

Distribute copies of the changed configuration files to each node.

With HDFS now running, make sure Accumulo has permission to create its
directory in HDFS, and initialize Accumulo:

```bash
sudo -u hdfs hdfs dfs -chmod 777 /
sudo -u accumulo accumulo init
```

After Accumulo has created its directory structure, you can change the
permissions for the root back to what they were:

```bash
sudo -u hdfs hdfs dfs -chmod 755 /
```

_Note: we only choose to do the above because this is a developer/testing
environment. Temporarily changing ownership of HDFS is not recommended for
the root of HDFS._

Now, you can start Accumulo.

On the NameNode, start all the Accumulo services and enable on reboot:

```bash
sudo systemctl start accumulo-{master,tserver,gc,tracer,monitor}.service
sudo systemctl enable accumulo-{master,tserver,gc,tracer,monitor}.service
```

On each DataNode, start just the `tserver` and enable it on reboot:

```bash
sudo systemctl start accumulo-tserver.service
sudo systemctl enable accumulo-tserver.service
```

## Watching and using Accumulo

### Run the shell

Run a shell as Accumulo's root user (the instance name and root password are
the ones you selected during the initialize step above:

```bash
accumulo shell -u root -zh <zk-dns-name>:2181 -zi <instanceName>
```

### View the monitor pages

You should also be able to view the NameNode monitor page and the Accumulo
monitor pages. If you are running this in EC2, you can view these over an SSH
tunnel using the NameNode's public IP address. If you didn't give this node a
public IP address, you can allocate one in EC2 and associate it with this node:

```bash
ssh -L50070:localhost:50070 -L50095:localhost:50095 <user>@<host>
```

Replace `<user>` with your username (probably `fedora` if using the Fedora
AMI), and `<host>` with the public IP or hostname for your EC2 instance. Now,
in your local browser, you should be able to navigate to these addresses in
your localhost: [Hadoop monitor (http://localhost:50070)][HMon] and [Accumulo
monitor (http://localhost:50095)][AMon].

## Debugging commands

Check the status of a service:

```bash
sudo systemctl status <ServiceName>.service
```

Check running Java processes:

```bash
sudo jps -ml
```

Check the system logs for a specific service within the last 10 minutes:

```bash
sudo journalctl -u <ServiceName> --since '10 minutes ago'
```

Check listening ports:

```bash
sudo netstat -tlnp
```

Check DNS name for a given IP address:

```bash
getent hosts <ipaddress> # OR
hostname -A
```

Perform forward and reverse DNS lookups:

```bash
sudo dnf install bind-utils
dig +short <hostname>     # forward DNS lookup
dig +short -x <ipaddress> # reverse DNS lookup
```

Find the instance ID for your instance name:

```bash
zkCli.sh -server <host>:2181     # replace <host> with your ZooKeeper server DNS name
> get /accumulo/instances/<name> # replace <name> with your instance name
> quit
```

If the NameNode is listening on the loopback address, you'll probably need to
restart the service manually, as well as any Accumulo services which failed.
This is a [known issue with Hadoop][HBug]:

```bash
sudo systemctl restart hadoop-namenode.service
```

Some helpful rpm commands:

```bash
rpm -q -i <installed-package-name>              # to see info about an installed package
rpm -q -i -p <rpm-file-name>                    # to see info about an rpm file
rpm -q --provides <installed-package-name>      # see what a package provides
rpm -q --requires <installed-package-name>      # see what a package requires
rpm -q -l <installed-package-name>              # list package files
rpm -q --whatprovides <file>                    # find rpm which owns <file>
rpm -q --whatrequires 'mvn(groupId:artifactId)' # find rpm which requires maven coords
```

## Helping out

Feel free to get involved with the [Fedora][FPackagers] or [Fedora EPEL][EPEL]
(for RHEL/CentOS users) packaging. Contact the Fedora [maintainers] (user `at`
fedoraproject `dot` org) for the Accumulo packages to see how you can help
patching bugs, adapting the upstream packages to the Fedora packaging
standards, testing updates, maintaining dependency packages, and more.

[Fedora]: https://getfedora.org/
[maintainers]: https://admin.fedoraproject.org/pkgdb/package/rpms/accumulo/
[bug]: https://bugzilla.redhat.com/show_bug.cgi?id=1404888
[HMon]: http://localhost:50070
[AMon]: http://localhost:50095
[HBug]: https://bugzilla.redhat.com/show_bug.cgi?id=1406165
[EPEL]: https://fedoraproject.org/wiki/EPEL
[FPackagers]: https://fedoraproject.org/wiki/Join_the_package_collection_maintainers
