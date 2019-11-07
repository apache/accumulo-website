---
title: "Checking API use"
---

Accumulo follows [SemVer] across versions with the declaration of a public API.  Code not in the public API should be
considered unstable, at risk of changing between versions.  The public API packages are [listed on the website][api]
but may not be considered when an Accumulo user writes code.  This blog post explains how to make Maven
automatically detect usage of Accumulo code outside the public API.

The techniques described in this blog post only work for Accumulo 2.0 and later.  Do not use with 1.X versions.

## Checkstyle Plugin

First add the checkstyle Maven plugin to your pom.

```xml
<plugin>
    <!-- This was added to ensure project only uses public API -->
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.1.0</version>
    <executions>
      <execution>
        <id>check-style</id>
        <goals>
          <goal>check</goal>
        </goals>
        <configuration>
          <configLocation>checkstyle.xml</configLocation>
        </configuration>
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

Create the second file specified above, ```import-control.xml``` and copy the configuration below.  Make sure to replace
"<insert-your-package-name>" with the package name of your project.
```xml
<!DOCTYPE import-control PUBLIC
    "-//Checkstyle//DTD ImportControl Configuration 1.4//EN"
    "https://checkstyle.org/dtds/import_control_1_4.dtd">

<!-- This checkstyle rule is configured to ensure only use of Accumulo API -->
<import-control pkg="<insert-your-package-name>" strategyOnMismatch="allowed">
    <!-- allow this package -->
    <allow pkg="<insert-your-package-name>"/>
    <!-- API packages -->
    <allow pkg="org.apache.accumulo.core.client"/>
    <allow pkg="org.apache.accumulo.core.data"/>
    <allow pkg="org.apache.accumulo.core.security"/>
    <allow pkg="org.apache.accumulo.core.iterators"/>
    <allow pkg="org.apache.accumulo.minicluster"/>
    <allow pkg="org.apache.accumulo.hadoop.mapreduce"/>

    <!-- disallow everything else coming from accumulo -->
    <disallow pkg="org.apache.accumulo"/>
</import-control>
```
This file configures the ImportControl module to only allow packages that are declared public API.

[SemVer]:  https://semver.org/
[api]: {{ site.baseurl }}/api/
[plugin]: https://maven.apache.org/plugins/maven-checkstyle-plugin/
