---
title: Monitoring & Metrics
category: administration
order: 2
---

## Monitoring

### Accumulo Monitor

The Accumulo Monitor provides a web UI with information on the health and status of Accumulo.

The monitor can be viewed at:
 * [http://localhost:9995](http://localhost:9995) - if Accumulo is running locally (for development)
 * `http://<MONITOR_HOST>:9995/` - if Accumulo is running on a cluster

The Overview page (shown below) contains some summary information about the Accumulo instance deployment and
instance, ingest, scan and compaction metrics.

<a class="p-3 border rounded d-block" href="{{ site.baseurl }}/images/accumulo4-monitor-1.png">
<img src="{{ site.baseurl }}/images/accumulo4-monitor-1.png" class="img-fluid rounded" alt="monitor overview"/>
</a>

The Monitor pages under the Servers menu display metrics for the server processes. The metrics are grouped into
separate tables where it makes sense to do so. Below is an example of the Managers page. The other pages under
the Server menu have a similar design.

<a class="p-3 border rounded d-block" href="{{ site.baseurl }}/images/accumulo4-monitor-2.png">
<img src="{{ site.baseurl }}/images/accumulo4-monitor-2.png" class="img-fluid rounded" alt="monitor manager"/>
</a>

The Tables Monitor page shows summary information for each table. Clicking on the link for a table will
take you to a page that shows more detailed information about that table.

The Activity drop-down has pages for Compaction, FaTE, Scan, and Tablet Recovery activity.
The Alerts page contains messages about the state of the instance. There are toggles in the settings
menu to show or hide the different alert priorities and categories.

The Accumulo monitor does a best-effort to not display any sensitive information to users; however,
the monitor is intended to be a tool used with care. It is not a production-grade webservice. It is
a good idea to whitelist access to the monitor via an authentication proxy or firewall. It
is strongly recommended that the Monitor is not exposed to any publicly-accessible networks.

### SSL

SSL may be enabled for the monitor page by setting the following properties in the `accumulo.properties` file:

 * {% plink monitor.ssl.keyStore %}
 * {% plink monitor.ssl.keyStorePassword %}
 * {% plink monitor.ssl.trustStore %}
 * {% plink monitor.ssl.trustStorePassword %}

If the Accumulo conf directory has been configured (in particular the `accumulo-env.sh` file must be set up), the
`accumulo-util gen-monitor-cert` command can be used to create the keystore and truststore files with random passwords. The command
will print out the properties that need to be added to the `accumulo.properties` file. The stores can also be generated manually with the
Java `keytool` command, whose usage can be seen in the `accumulo-util` script.

If desired, the SSL ciphers allowed for connections can be controlled via the following properties in `accumulo.properties`:

 * {% plink monitor.ssl.include.ciphers %}
 * {% plink monitor.ssl.exclude.ciphers %}

If SSL is enabled, the monitor URL can only be accessed via https.
This also allows you to access the Accumulo shell through the monitor page.
The left navigation bar will have a new link to Shell.
An Accumulo user name and password must be entered for access to the shell.

## Metrics

Accumulo can emit metrics using the [Micrometer] library. Support for the Hadoop Metrics2 framework was removed in version 2.1.0.

### Configuration

Micrometer supports sending metrics to multiple monitoring systems. A Metrics sink in Micrometer is called a
Meter Registry. To enable this feature you need to set the property [general.micrometer.enabled] to `true` and
optionally set [general.micrometer.jvm.metrics.enabled] to `true` to include [jvm] metrics. Accumulo provides a
mechanism for the user to specify which Meter Registry it should use with the property [general.micrometer.factory].
The value for this property should be the name of a class that implements
{% jlink org.apache.accumulo.core.metrics.MeterRegistryFactory %}.

Each server process should have log messages from the org.apache.accumulo.core.metrics.MetricsUtil class that details
whether or not metrics are enabled and which MeterRegistryFactory class has been configured. Be sure to check the
Accumulo processes log files when debugging missing metrics output.

### Metric Names

See the javadoc for {% jlink org.apache.accumulo.core.metrics.MetricsProducer %} for a list of metric names that will be
emitted and a mapping to their prior names when Accumulo was using Hadoop Metrics2.

[Micrometer]: https://micrometer.io/
[general.micrometer.enabled]: {% purl general.micrometer.enabled %}
[general.micrometer.jvm.metrics.enabled]: {% purl general.micrometer.jvm.metrics.enabled %}
[general.micrometer.factory]: {% purl general.micrometer.factory %}
[jvm]: https://micrometer.io/docs/ref/jvm
[tracing]: {% durl troubleshooting/tracing %}
