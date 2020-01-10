---
title: Proxy
category: development
order: 7
---

The [Accumulo Proxy] allows the interaction with Accumulo with languages other than Java.
A proxy server is provided in the codebase and a client can further be generated.
The proxy API can also be used instead of the traditional [AccumuloClient] class to
provide a single TCP port in which clients can be securely routed through a firewall,
without requiring access to all tablet servers in the cluster.

## Prerequisites

The proxy server can live on any node in which the basic client API would work. That
means it must be able to communicate with the Master, ZooKeepers, NameNode, and the
DataNodes. A proxy client only needs the ability to communicate with the proxy server.

## Running the Proxy Server

To run [Accumulo Proxy] server, first clone the repository:

```bash
git clone https://github.com/apache/accumulo-proxy
```

Next, follow the instructions in the Proxy [README.md] or use [Uno] to run the proxy.

To run the Proxy using [Uno], configure `uno.conf` to start the Proxy by setting the
configuration below:

```
export POST_RUN_PLUGINS="accumulo-proxy"
export PROXY_REPO=/path/to/accumulo-proxy
```

## Proxy Client Examples

The following examples show proxy clients written in Java, Ruby, and Python.

### Ruby

The [Accumulo Proxy] repo has an example [ruby client] along with [instructions][rubyinstruct] on how
to run it.

### Python

The [Accumulo Proxy] repo has two example Python scripts that can be run using these [instructions][pythoninstruct]:
 * [basic client] - creates a table, writes data to it, and then reads it
 * [namespace client] - shows how to manage Accumulo namespaces.

### Java

Users may want to write a [Java client] to the proxy to restrict access to the cluster.

[Accumulo Proxy]: https://github.com/apache/accumulo-proxy/
[Uno]: https://github.com/apache/fluo-uno/
[README.md]: https://github.com/apache/accumulo-proxy/blob/master/README.md
[Java client]: https://github.com/apache/accumulo-proxy/docs/java_client.md
[ruby client]: https://github.com/apache/accumulo-proxy/src/main/ruby/client.rb
[pythoninstruct]: https://github.com/apache/accumulo-proxy/#create-an-accumulo-client-using-python
[rubyinstruct]: https://github.com/apache/accumulo-proxy/#create-an-accumulo-client-using-ruby
[basic client]: https://github.com/apache/accumulo-proxy/blob/master/src/main/python/basic_client.py
[namespace client]: https://github.com/apache/accumulo-proxy/blob/master/src/main/python/namespace_client.py
[AccumuloClient]: {% jurl org.apache.accumulo.core.client.AccumuloClient %}
[tutorial]: https://thrift.apache.org/tutorial/
