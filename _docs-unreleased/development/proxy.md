---
title: Proxy
category: development
order: 3
---

The proxy API allows the interaction with Accumulo with languages other than Java.
A proxy server is provided in the codebase and a client can further be generated.
The proxy API can also be used instead of the traditional [ZooKeeperInstance] class to
provide a single TCP port in which clients can be securely routed through a firewall,
without requiring access to all tablet servers in the cluster.

## Prerequisites

The proxy server can live on any node in which the basic client API would work. That
means it must be able to communicate with the Master, ZooKeepers, NameNode, and the
DataNodes. A proxy client only needs the ability to communicate with the proxy server.

## Running the Proxy Server

The proxy server is included in the Accumulo tarball distribution and can be run using
the `accumulo` or `accumulo-service` command. A sample proxy configuration file can be found at
`conf/templates/proxy.properties`. Create a copy of this file and edit it for your environment:

    cp ./conf/templates/proxy.properties ./conf/
    vim ./conf/proxy.properties

At the very least, you need to configure the following properties:

    instance=test
    zookeepers=localhost:2181
    port=42424
    protocolFactory=org.apache.thrift.protocol.TCompactProtocol$Factory
    tokenClass=org.apache.accumulo.core.client.security.tokens.PasswordToken

After `proxy.properties` is configured, the proxy server can be started using the `accumulo`
or `accumulo-service` commands:

To start the proxy in the foreground and log to the console, use the `accumulo` command:

    accumulo proxy -p /path/to/proxy.properties

To background the process and redirect logs, use the `accumulo-service` command (a `proxy.properties`
file must exist in `conf/` if using this method):

    accumulo-service proxy start

## Prerequisites for Proxy Clients

Before you can run a proxy client, you will need the following:

1. Proxy client code generated for your language
2. Thrift library installed for your language

These requirements are described in detail below.

### Proxy client code

The Accumulo tarball distribution ships with pre-generated client code for Python, Ruby, and C++ in
`lib/proxy`.

If you want to write a proxy in another language, you will need to install Thrift and generate
client code for you language using `lib/proxy/thrift/proxy.thrift`.  See the [Thrift Tutorial][tutorial]
to how generate source from a thrift file.

### Thrift library

Language-specific Thrift libraries can be installed using an OS or language package manager (i.e gem, pip, etc).
For example, `pip install thrift` will install Python-specific thrift libaries on your machine.

## Proxy Client Examples

The following examples show proxy clients written in Java, Ruby, and Python.

### Java

After initiating a connection to the Proxy (see Apache Thrift's documentation for examples
of connecting to a Thrift service), the methods on the proxy client will be available. The
first thing to do is log in:

```java
Map password = new HashMap<String,String>();
password.put("password", "secret");
ByteBuffer token = client.login("root", password);
```

Once logged in, the token returned will be used for most subsequent calls to the client.
Let's create a table, add some data, scan the table, and delete it.

First, create a table.

```java
client.createTable(token, "myTable", true, TimeType.MILLIS);
```

Next, add some data:

```java
// first, create a writer on the server
String writer = client.createWriter(token, "myTable", new WriterOptions());

//rowid
ByteBuffer rowid = ByteBuffer.wrap("UUID".getBytes());

//mutation like class
ColumnUpdate cu = new ColumnUpdate();
cu.setColFamily("MyFamily".getBytes());
cu.setColQualifier("MyQualifier".getBytes());
cu.setColVisibility("VisLabel".getBytes());
cu.setValue("Some Value.".getBytes());

List<ColumnUpdate> updates = new ArrayList<ColumnUpdate>();
updates.add(cu);

// build column updates
Map<ByteBuffer, List<ColumnUpdate>> cellsToUpdate = new HashMap<ByteBuffer, List<ColumnUpdate>>();
cellsToUpdate.put(rowid, updates);

// send updates to the server
client.updateAndFlush(writer, "myTable", cellsToUpdate);

client.closeWriter(writer);
```

Scan for the data and batch the return of the results on the server:

```java
String scanner = client.createScanner(token, "myTable", new ScanOptions());
ScanResult results = client.nextK(scanner, 100);

for(KeyValue keyValue : results.getResultsIterator()) {
  // do something with results
}

client.closeScanner(scanner);
```

### Ruby

The example ruby code below can be run using the following command (the -I option is needed for ruby 1.9.x):

    ruby -I . client.rb <host of server>

**Warning:** The script will connect to Accumulo, create a table, and add some rows to it.

```ruby
require 'rubygems'
require 'thrift'
require 'accumulo_proxy'

server = ARGV[0] || 'localhost'

socket = Thrift::Socket.new(server, 42424, 9001)
transport = Thrift::FramedTransport.new(socket)
proto = Thrift::CompactProtocol.new(transport)
proxy = Accumulo::AccumuloProxy::Client.new(proto)

# open up the connect
transport.open()

# Test if the server is up
login = proxy.login('root', {'password' => 'secret'})

# print out a table list
puts "List of tables: #{proxy.listTables(login).inspect}"

testtable = "rubytest"
proxy.createTable(login, testtable, true, Accumulo::TimeType::MILLIS) unless proxy.tableExists(login,testtable) 

update1 = Accumulo::ColumnUpdate.new({'colFamily' => "cf1", 'colQualifier' => "cq1", 'value'=> "a"})
update2 = Accumulo::ColumnUpdate.new({'colFamily' => "cf2", 'colQualifier' => "cq2", 'value'=> "b"})
proxy.updateAndFlush(login,testtable,{'row1' => [update1,update2]})

cookie = proxy.createScanner(login,testtable,nil)
result = proxy.nextK(cookie,10)
result.results.each{ |keyvalue| puts "Key: #{keyvalue.key.inspect} Value: #{keyvalue.value}" }
```

### Python

The example python client code below (if saved to TestClient.py) can be run using the following command:

    PYTHONPATH=/path/to/accumulo-{{ page.latest_release }}/lib/proxy/gen-py python TestClient.py

As a warning, this script will create a table in your Accumulo instance and add a few cells to it.

```python
#! /usr/bin/env python

import sys

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TCompactProtocol

from accumulo import AccumuloProxy
from accumulo.ttypes import *

transport = TSocket.TSocket('localhost', 42424)
transport = TTransport.TFramedTransport(transport)
protocol = TCompactProtocol.TCompactProtocol(transport)
client = AccumuloProxy.Client(protocol)
transport.open()

login = client.login('root', {'password':'secret'})

print client.listTables(login)

testtable = "pythontest"
if not client.tableExists(login, testtable):
    client.createTable(login, testtable, True, TimeType.MILLIS)

row1 = {'a':[ColumnUpdate('a','a',value='value1'), ColumnUpdate('b','b',value='value2')]}
client.updateAndFlush(login, testtable, row1)

cookie = client.createScanner(login, testtable, None)
for entry in client.nextK(cookie, 10).results:
   print entry
```

The example code below shows proxy client code for managing namespaces:

```python
#! /usr/bin/env python

from thrift.protocol import TCompactProtocol
from thrift.transport import TSocket, TTransport

from proxy import AccumuloProxy
from proxy.ttypes import NamespacePermission, IteratorSetting, IteratorScope, AccumuloException

def main():
    transport = TSocket.TSocket('localhost', 42424)
    transport = TTransport.TFramedTransport(transport)
    protocol = TCompactProtocol.TCompactProtocol(transport)
    client = AccumuloProxy.Client(protocol)
    transport.open()
    login = client.login('root', {'password': 'password'})

    client.createLocalUser(login, 'user1', 'password1')

    print client.listNamespaces(login)

    # create a namespace and give the user1 all permissions
    print 'creating namespace testing'
    client.createNamespace(login, 'testing')
    assert client.namespaceExists(login, 'testing')
    print client.listNamespaces(login)

    print 'testing namespace renaming'
    client.renameNamespace(login, 'testing', 'testing2')
    assert not client.namespaceExists(login, 'testing')
    assert client.namespaceExists(login, 'testing2')
    client.renameNamespace(login, 'testing2', 'testing')
    assert not client.namespaceExists(login, 'testing2')
    assert client.namespaceExists(login, 'testing')

    print 'granting all namespace permissions to user1'
    for k, v in NamespacePermission._VALUES_TO_NAMES.iteritems():
        client.grantNamespacePermission(login, 'user1', 'testing', k)

    # make sure the last operation worked
    for k, v in NamespacePermission._VALUES_TO_NAMES.iteritems():
        assert client.hasNamespacePermission(login, 'user1', 'testing', k), \
            'user1 does\'nt have namespace permission %s' % v

    print 'default namespace: ' + client.defaultNamespace()
    print 'system namespace: ' + client.systemNamespace()

    # grab the namespace properties
    print 'retrieving namespace properties'
    props = client.getNamespaceProperties(login, 'testing')
    assert props and props['table.compaction.major.ratio'] == '3'

    # update a property and verify it is good
    print 'setting namespace property table.compaction.major.ratio = 4'
    client.setNamespaceProperty(login, 'testing', 'table.compaction.major.ratio', '4')
    props = client.getNamespaceProperties(login, 'testing')
    assert props and props['table.compaction.major.ratio'] == '4'

    print 'retrieving namespace ID map'
    nsids = client.namespaceIdMap(login)
    assert nsids and 'accumulo' in nsids

    print 'attaching debug iterator to namespace testing'
    setting = IteratorSetting(priority=40, name='DebugTheThings',
                              iteratorClass='org.apache.accumulo.core.iterators.DebugIterator', properties={})
    client.attachNamespaceIterator(login, 'testing', setting, [IteratorScope.SCAN])
    setting = client.getNamespaceIteratorSetting(login, 'testing', 'DebugTheThings', IteratorScope.SCAN)
    assert setting and setting.name == 'DebugTheThings'

    # make sure the iterator is in the list
    iters = client.listNamespaceIterators(login, 'testing')
    found = False
    for name, scopes in iters.iteritems():
        if name == 'DebugTheThings':
            found = True
            break
    assert found

    print 'checking for iterator conflicts'

    # this next statment should be fine since we are on a different scope
    client.checkNamespaceIteratorConflicts(login, 'testing', setting, [IteratorScope.MINC])

    # this time it should throw an exception since we have already added the iterator with this scope
    try:
        client.checkNamespaceIteratorConflicts(login, 'testing', setting, [IteratorScope.SCAN, IteratorScope.MINC])
    except AccumuloException:
        pass
    else:
        assert False, 'There should have been a namespace iterator conflict!'

    print 'removing debug iterator from namespace testing'
    client.removeNamespaceIterator(login, 'testing', 'DebugTheThings', [IteratorScope.SCAN])

    # make sure the iterator is NOT in the list anymore
    iters = client.listNamespaceIterators(login, 'testing')
    found = False
    for name, scopes in iters.iteritems():
        if name == 'DebugTheThings':
            found = True
            break
    assert not found

    print 'adding max mutation size namespace constraint'
    constraintid = client.addNamespaceConstraint(login, 'testing',
                                                 'org.apache.accumulo.test.constraints.MaxMutationSize')

    print 'make sure constraint was added'
    constraints = client.listNamespaceConstraints(login, 'testing')
    found = False
    for name, cid in constraints.iteritems():
        if cid == constraintid and name == 'org.apache.accumulo.test.constraints.MaxMutationSize':
            found = True
            break
    assert found

    print 'remove max mutation size namespace constraint'
    client.removeNamespaceConstraint(login, 'testing', constraintid)

    print 'make sure constraint was removed'
    constraints = client.listNamespaceConstraints(login, 'testing')
    found = False
    for name, cid in constraints.iteritems():
        if cid == constraintid and name == 'org.apache.accumulo.test.constraints.MaxMutationSize':
            found = True
            break
    assert not found

    print 'test a namespace class load of the VersioningIterator'
    res = client.testNamespaceClassLoad(login, 'testing', 'org.apache.accumulo.core.iterators.user.VersioningIterator',
                                        'org.apache.accumulo.core.iterators.SortedKeyValueIterator')
    assert res

    print 'test a bad namespace class load of the VersioningIterator'
    res = client.testNamespaceClassLoad(login, 'testing', 'org.apache.accumulo.core.iterators.user.VersioningIterator',
                                        'dummy')
    assert not res

    # revoke the permissions
    print 'revoking namespace permissions for user1'
    for k, v in NamespacePermission._VALUES_TO_NAMES.iteritems():
        client.revokeNamespacePermission(login, 'user1', 'testing', k)

    # make sure the last operation worked
    for k, v in NamespacePermission._VALUES_TO_NAMES.iteritems():
        assert not client.hasNamespacePermission(login, 'user1', 'testing', k), \
            'user1 does\'nt have namespace permission %s' % v

    print 'deleting namespace testing'
    client.deleteNamespace(login, 'testing')
    assert not client.namespaceExists(login, 'testing')

    print 'deleting user1'
    client.dropLocalUser(login, 'user1')

if __name__ == "__main__":
    main()
```

[ZookeeperInstance]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/ZooKeeperInstance.html
[tutorial]: https://thrift.apache.org/tutorial/
