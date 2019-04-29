---
title: Testing a release
---

## Test a Accumulo release

1. Set the release version, ID for staging repo, and alias to configure Maven with temporary settings:
   ```shell
   export RC_VERSION=1.9.0
   export RC_STAGING=1070
   ```
1. Create temporary Maven settings
   ```shell
   $ cat <<EOF >/tmp/accumulo-rc-maven.xml
   <settings>
     <profiles>
       <profile>
         <id>accumuloRC</id>
         <repositories>
           <repository>
             <id>accumulorc</id>
             <name>accumulorc</name>
             <url>https://repository.apache.org/content/repositories/orgapacheaccumulo-\${env.RC_STAGING}/</url>
           </repository>
         </repositories>
         <pluginRepositories>
           <pluginRepository>
             <id>accumulorcp</id>
             <name>accumulorcp</name>
             <url>https://repository.apache.org/content/repositories/orgapacheaccumulo-\${env.RC_STAGING}/</url>
           </pluginRepository>
         </pluginRepositories>
       </profile>
     </profiles>
     <activeProfiles>
       <activeProfile>accumuloRC</activeProfile>
     </activeProfiles>
   </settings>
   EOF
   ```
#### Run the integration tests of projects that use Accumulo

1. Clone the [Accumulo Examples] project:
    ```shell
    $ git clone https://github.com/apache/accumulo-examples.git
    ```
1. Run the integration test
    ```shell
    $ mvn -s /tmp/accumulo-rc-maven.xml clean verify -Daccumulo.version=$RC_VERSION
    ```
Below are more projects with integration tests:
* [Wikisearch] - `https://github.com/apache/accumulo-wikisearch`
* [Apache Fluo] - `https://github.com/apache/fluo`

[Accumulo Examples]: https://github.com/apache/accumulo-examples
[WikiSearch]: https://github.com/apache/accumulo-wikisearch
[Apache Fluo]: https://github.com/apache/fluo
