---
title: Accumulo Clients in Other Programming Languages
---

Apache Accumulo has an [Accumulo Proxy] that allows communication with Accumulo using clients written
in languages other than Java. This blog post shows how to run the Accumulo Proxy process using [Uno]
and communicate with Accumulo using a Python client.

First, clone the [Accumulo Proxy] repository.

```bash
git clone https://github.com/apache/accumulo-proxy
```

Assuming you have [Uno] set up on your machine, configure `uno.conf` to start the [Accumulo Proxy]
by setting the configuration below:

```
export POST_RUN_PLUGINS="accumulo-proxy"
export PROXY_REPO=/path/to/accumulo-proxy
```

Run the following command to set up Accumulo again. The Proxy will be started after Accumulo runs.

```
uno setup accumulo
```

After Accumulo is set up, you should see the following output from uno:

```
Executing post run plugin: accumulo-proxy
Installing Accumulo Proxy at /path/to/fluo-uno/install/accumulo-proxy-2.0.0-SNAPSHOT
Accumulo Proxy 2.0.0-SNAPSHOT is running
    * view logs at /path/to/fluo-uno/install/logs/accumulo-proxy/
```

Next, follow the instructions below to create a Python 2.7 client that creates an Accumulo table
named `pythontest` and writes data to it:

```
mkdir accumulo-client/
cd accumulo-client/
pipenv --python 2.7
pipenv install thrift
pipenv install -e /path/to/accumulo-proxy/src/main/python
cp /path/to/accumulo-proxy/src/main/python/basic_client.py .
# Edit credentials if needed
vim basic_client.py
pipenv run python2 basic_client.py
```

Verify that the table was created or data was written using `uno ashell` or the Accumulo monitor.

[Uno]: https://github.com/apache/fluo-uno
[Accumulo Proxy]: https://github.com/apache/accumulo-proxy
