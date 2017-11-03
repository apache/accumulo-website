---
title: "Simpler scripts and configuration coming in Accumulo 2.0.0"
author: Mike Walch
---

For the upcoming 2.0.0 release, Accumulo's scripts and configuration [were refactored][ACCUMULO-4490]
to make Accumulo easier to use. While Accumulo's documentation (i.e. the user
manual and [INSTALL.md]) were updated with any changes that were made, this blog post provides
a summary of the changes.

### Fewer scripts

Before 2.0.0, the `bin/` directory of Accumulo's binary tarball contained about 20 scripts:

```bash
$ ls accumulo-1.8.0/bin/
accumulo             build_native_library.sh  generate_monitor_certificate.sh  start-here.sh    stop-server.sh
accumulo_watcher.sh  check-slaves             LogForwarder.sh                  start-server.sh  tdown.sh
bootstrap_config.sh  config-server.sh         start-all.sh                     stop-all.sh      tool.sh
bootstrap_hdfs.sh    config.sh                start-daemon.sh                  stop-here.sh     tup.sh
```

The number of scripts made it difficult to know which scripts to use.  If you added the `bin/` directory to your 
`PATH`, it could add unnecessary commands to your PATH or cause commands to be overridden due generic names
(like 'start-all.sh'). The number of scripts were reduced by removing scripts that are no longer used and combining
scripts with similar functionality.

Starting with 2.0.0, Accumulo will only have 4 scripts in its `bin/` directory:

```bash
$ ls accumulo-2.0.0/bin/
accumulo  accumulo-cluster  accumulo-service  accumulo-util
```

Below are some notes on this change:

* The 'accumulo' script was mostly left alone except for improved usage.
* The 'accumulo-service' script was created to manage Accumulo processes as services
* The 'accumulo-cluster' command was created to manage Accumulo on cluster and replaces 'start-all.sh' and 'stop-all.sh'.
* The 'accumulo-util' command combines many utility scripts such as 'build_native_library.sh', 'tool.sh', etc into one script.

### Less configuration

Before 2.0.0, Accumulo's `conf/` directory looked like the following (after creating initial config files
using 'bootstrap_config.sh'):

```bash
$ ls accumulo-1.8.0/conf/
accumulo-env.sh          auditLog.xml  generic_logger.properties            masters                    slaves
accumulo-metrics.xml     client.conf   generic_logger.xml                   monitor                    templates
accumulo.policy.example  examples      hadoop-metrics2-accumulo.properties  monitor_logger.properties  tracers
accumulo-site.xml        gc            log4j.properties                     monitor_logger.xml
```

While all of these files have a purpose, many are only used in rare situations. For Accumulo 2.0, the 'conf/'
directory now only contains a minimum set of configuration files needed to run Accumulo.

```bash
$ ls accumulo-2.0.0/conf/
accumulo-env.sh  accumulo-site.xml  client.conf  log4j-monitor.properties  log4j.properties  log4j-service.properties  templates
```

The Accumulo tarball does contain host files (i.e 'tservers', 'monitor', etc) by default as these files are only required by
the 'accumulo-cluster' command. However, the script has a command to generate them.

```bash
$ ./bin/accumulo-cluster create-config
```

Any less common configuration files can still be found in `conf/templates`.

### Better usage

Before 2.0.0, the 'accumulo' command had a limited usage:

```
$ ./accumulo-1.8.0/bin/accumulo
accumulo admin | check-server-config | classpath | create-token | gc | help | info | init | jar <jar> [<main class>] args |
  login-info | master | minicluster | monitor | proxy | rfile-info | shell | tracer | tserver | version | zookeeper | <accumulo class> args
```

For 2.0.0, all 'accumulo' commands were given a short description and organized into the groups.  Below is
the full usage. It should be noted that usage is limited until the 'accumulo-env.sh' configuration file is
created in `conf/` by the `accumulo create-config` command.

```
$ ./accumulo-2.0.0/bin/accumulo help

Usage: accumulo <command> [-h] (<argument> ...)

  -h   Prints usage for specified command

Core Commands:
  init                           Initializes Accumulo
  shell                          Runs Accumulo shell
  classpath                      Prints Accumulo classpath
  version                        Prints Accumulo version
  admin                          Executes administrative commands
  info                           Prints Accumulo cluster info
  help                           Prints usage
  <main class> args              Runs Java <main class> located on Accumulo classpath

Process Commands:
  gc                             Starts Accumulo garbage collector
  master                         Starts Accumulo master
  monitor                        Starts Accumulo monitor
  minicluster                    Starts Accumulo minicluster
  proxy                          Starts Accumulo proxy
  tserver                        Starts Accumulo tablet server
  tracer                         Starts Accumulo tracer
  zookeeper                      Starts Apache Zookeeper instance

Advanced Commands:
  check-server-config            Checks server config
  create-token                   Creates authentication token
  login-info                     Prints Accumulo login info
  rfile-info                     Prints rfile info
```

The new 'accumulo-service' and 'accumulo-cluster' commands also have informative usage.

```
$ ./accumulo-2.0.0/bin/accumulo-service 

Usage: accumulo-service <service> <command>

Services:
  gc          Accumulo garbage collector
  monitor     Accumulo monitor
  master      Accumulo master
  tserver     Accumulo tserver
  tracer      Accumulo tracer

Commands:
  start       Starts service
  stop        Stops service
  kill        Kills service

$ ./accumulo-2.0.0/bin/accumulo-cluster 

Usage: accumulo-cluster <command> (<argument> ...)

Commands:
  create-config       Creates cluster config
  start               Starts Accumulo cluster
  stop                Stops Accumulo cluster
  start-non-tservers  Starts all services except tservers
  start-tservers      Starts all tservers on cluster
  stop-tservers       Stops all tservers on cluster
  start-here          Starts all services on this node
  stop-here           Stops all services on this node
```

*This post was updated on March 24, 2017 to reflect changes to Accumulo 2.0*

[ACCUMULO-4490]: https://issues.apache.org/jira/browse/ACCUMULO-4490
[INSTALL.md]: https://github.com/apache/accumulo/blob/master/INSTALL.md
