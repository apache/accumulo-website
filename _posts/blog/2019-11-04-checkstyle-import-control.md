---
title: "Checking API use"
---

Accumulo follows [SemVer] across versions with the declaration of a public API.  Code not in the public API should be
considered unstable, at risk of changing between versions.  The packages included in the public API are [listed on the website][api]
but may not always be considered when developing using Accumulo code.  This blog post explains how to setup a Maven project
to automatically detect when Accumulo 2.0 code used in the project is outside of the public API.

## Checkstyle Plugin

First add the checkstyle Maven plugin to your pom.

```xml
<plugin>
    <!-- This was added to ensure project only uses public API -->
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.1.0</version>
    <configuration>
      <configLocation>checkstyle.xml</configLocation>
    </configuration>
    <dependencies>
      <dependency>
        <groupId>com.puppycrawl.tools</groupId>
        <artifactId>checkstyle</artifactId>
        <version>8.23</version>
      </dependency>
    </dependencies>
    <executions>
      <execution>
        <id>check-style</id>
        <goals>
          <goal>check</goal>
        </goals>
      </execution>
    </executions>
  </plugin>
```
The plugin version is the latest at the time of this post.  For more information see the website for
the [Apache Maven Checkstyle Plugin][plugin].  The configuration above adds the plugin to ```check``` execution goal
so it will always run with your build.  

Create the configuration file specified above: ```checkstyle.xml```

### checkstyle.xml

```xml
<!DOCTYPE module PUBLIC "-//Puppy Crawl//DTD Check Configuration 1.3//EN" "http://www.puppycrawl.com/dtds/configuration_1_3.dtd">
<module name="Checker">
  <property name="charset" value="UTF-8"/>
  <module name="TreeWalker">
    <!--check that only Accumulo public APIs are imported-->
    <module name="ImportControl">
      <property name="file" value="import-control.xml"/>
    </module>
  </module>
</module>
```
This file sets up the ImportControl module.

## Import Control Configuration

Create the second file specified above, ```import-control.xml``` and copy the configuration below:
```xml
<!DOCTYPE import-control PUBLIC
    "-//Checkstyle//DTD ImportControl Configuration 1.4//EN"
    "https://checkstyle.org/dtds/import_control_1_4.dtd">

<!-- This checkstyle rule is configured to ensure only use of Accumulo API -->
<import-control pkg="org.apache.accumulo.testing" strategyOnMismatch="allowed">
    <!-- allow this package -->
    <allow pkg="org.apache.accumulo.testing"/>
    <!-- API packages -->
    <allow pkg="org.apache.accumulo.core.client"/>
    <allow pkg="org.apache.accumulo.core.data"/>
    <allow pkg="org.apache.accumulo.core.security"/>
    <allow pkg="org.apache.accumulo.core.iterators"/>
    <allow pkg="org.apache.accumulo.minicluster"/>
    <allow pkg="org.apache.accumulo.hadoop.mapreduce"/>

    <!-- SPI package -->
    <allow pkg="org.apache.accumulo.core.spi"/>

    <!-- disallow everything else coming from accumulo -->
    <disallow pkg="org.apache.accumulo"/>
</import-control>
```
This file configures the ImportControl module to only allow packages that are declared public API.

[SemVer]:  https://semver.org/
[api]: {{ site.baseurl }}/api/
[plugin]: https://maven.apache.org/plugins/maven-checkstyle-plugin/