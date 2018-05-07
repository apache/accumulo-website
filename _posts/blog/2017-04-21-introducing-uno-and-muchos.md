---
title: "Introducing Uno and Muchos"
author: Mike Walch
---

While [Accumulo's installation instructions][install] are simple, it can be time consuming to install Accumulo
given its requirement on [Hadoop] and [Zookeeper] being installed and running. For a one-time production
installation, this set up time (which can take up to an hour) is not much of an inconvenience. However, it can become a burden
for developers who need to frequently set up Accumulo to test code changes, switch between different
versions, or start a fresh instance on a laptop.

[Uno] and [Muchos] are tools that ease the burden on developers of installing Accumulo and its dependencies.
The names of Uno and Muchos indicate their use case. Uno is designed for running Accumulo on a single node
while Muchos is designed for running Accumulo on a cluster. While Uno and Muchos will install by default the most
recent stable release of Accumulo, Hadoop, and Zookeeper, it is easy to configure different versions to
match a production cluster.

The sections below show how to use these tools. For more complete documentation, view their respective GitHub
pages.

## Uno

[Uno] is a command line tool that sets up Accumulo on a single machine. It can be installed by cloning the
Uno git repo.

```bash
git clone https://github.com/apache/fluo-uno.git
cd fluo-uno
```

Uno works out of the box but it can be customized by modifying `conf/uno.conf`.

First, download the Accumulo, Hadoop, and Zookeeper tarballs from Apache by using the command below:

```bash
./bin/uno fetch accumulo
```

The fetch command places all tarballs in the `downloads/` directory. Uno can be configured (in `conf/uno.conf`)
to build an Accumulo tarball from a local git repo when `fetch` is called.

After downloading tarballs, the command below sets up Accumulo, Hadoop & Zookeeper in the `install/` directory.

```bash
./bin/uno setup accumulo
```

Accumulo, Hadoop, & Zookeeper are now ready to use. You can view the Accumulo monitor at
[http://localhost:9995](http://localhost:9995). You can configure your shell using the command below:

```bash
eval "$(./bin/uno env)"
```

Run `uno stop accumulo` to cleanly stop your cluster and `uno start accumulo` to start it again.

If you need a fresh cluster, you can run `uno setup accumulo` again. To kill your cluster, run `uno kill`.

## Muchos

[Muchos] is a command line tool that launches an AWS EC2 cluster with Accumulo set up on it. It is installed by
cloning its git repo.

```bash
git clone https://github.com/apache/fluo-muchos.git
cd fluo-muchos
```

Before using Muchos, create `muchos.props` in `conf/` and edit it for your AWS environment.

```bash
cp conf/muchos.props.example conf/muchos.props
vim conf/muchos.props
```

Next, run the command below to launch a cluster in AWS.

```bash
muchos launch -c mycluster
```

After launching the cluster, set up Accumulo on it using the following command.

```bash
muchos setup
```

Use `muchos ssh` to ssh to the cluster and `muchos terminate` to terminate all EC2 nodes when you are finished.

## Conclusion

Uno and Muchos automate installing Accumulo for development and testing. While not recommended for production
use at this time, Muchos is a great reference for running Accumulo in production. System administrators can
reference the [Ansible] code in Muchos to automate management of their own clusters.

[install]: https://github.com/apache/accumulo/blob/master/INSTALL.md
[Hadoop]: https://hadoop.apache.org/
[Zookeeper]: https://zookeeper.apache.org/
[Uno]: https://github.com/apache/fluo-uno
[Muchos]: https://github.com/apache/fluo-muchos
[Ansible]: https://www.ansible.com/
