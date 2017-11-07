---
title: Verifying a Release
redirect_from: /verifying_releases
---

This is a guide for the verification of a release candidate of Apache Accumulo. These steps are meant to encapsulate
the requirements of the PMC set forth by the Foundation itself.

The information here is meant to be an application of Foundation policy. When in doubt or conflict, any Foundation-level
trumps anything written here.

## Versioning

Accumulo has adopted [Semantic Versioning][semver] and follows their rules and guidelines.

## Testing basics

Each release of Accumulo should be tested by the community to verify correctness. 

Below are some suggested tests that can be run (feel free to run your own custom tests too):

* Run Accumulo's unit and integration tests using the following command:

        $ mvn verify

* Build the [Accumulo Examples][examples] repo using the release candidate by updating the `accumulo.version`
  property in the `pom.xml` and using the staging repo. Also, run the unit/integration tests using `mvn verify`.

* Run Accumulo's distributed tests (i.e. random walk, continuous ingest). These tests are intended to be run for days
  on end while injecting faults into the system. These are the tests that truly verify the correctness of Accumulo on
  real systems. Starting with 2.0, these tests are run using the [Accumulo Testing repo][at]. See the [README.md][at-readme]
  for more information.  Before 2.0, these tests are found in Accumulo tarball at `test/system/randomwalk` and
  `test/system/continuous` which include instructions on how to run the tests.

## Project testing goals

While contributors do not need perform all tests, there should a minimum amount of testing done by the project as whole before a release is made.

Testing for an Accumulo release includes a few steps that a developer may take without a Hadoop cluster and several that require a working cluster. For minor releases, 
the tests which run on a Hadoop cluster are recommended to be completed but are not required. Running even a reduced set of tests against real hardware is always encouraged
even if the full test suite (in breadth of nodes or duration) is not executed. If PMC members do not believe adequate testing was performed for the sake of making the proposed
release, the release should be vetoed via the normal voting process. New major releases are expected to run a full test suite.

### Stand alone

The following steps can be taken without having an underlying cluster. They SHOULD be handled with each Hadoop profile available for a given release version. To activate an alternative profile specify e.g. "-Dhadoop.profile=2" for the Hadoop 2 profile on the Maven commandline. Some older versions of Accumulo referred to Hadoop profiles differently; see the README that came with said versions for details on building against different Hadoop versions.

  1. All JUnit tests must pass.  This should be a requirement of any patch so it should never be an issue of the codebase.
    - Use "mvn package" to run against the default profile of a particular release
    - Use "mvn -Dhadoop.profile=2 package" to test against the Hadoop 2 profile on e.g. 1.4 or 1.5
    - Use "mvn -Dhadoop.profile=1 package" to test against the Hadoop 1 profile on e.g. 1.6 or later
  - Analyze output of static analysis tools like Findbugs and PMD.
  - For versions 1.6 and later, all functional tests must pass via the Maven failsafe plugin.
    - Use "mvn verify" to run against the default profile of a particular release
    - Use "mvn -Dhadoop.profile=1 verify" to run the functional tests against the Hadoop 1 profile

### Cluster based

The following tests require a Hadoop cluster running a minimum of HDFS, MapReduce, and ZooKeeper. The cluster MAY have any number of worker nodes; it can even be a single node in pseudo-distributed mode. A cluster with multiple tablet servers SHOULD be used so that more of the code base will be exercised. For the purposes of release testing, you should note the number of nodes and versions used. See the Releasing section for more details.

  1. For versions prior to 1.6, all functional tests must complete successfully.
    - See $ACCUMULO_HOME/test/system/auto/README for details on running the functional tests.
  - Two 24-hour periods of the LongClean module of the RandomWalk test need to be run successfully. One of them must use agitation and the other should not.
    - See $ACCUMULO_HOME/test/system/randomwalk/README for details on running the LongClean module.
  - Two 24-hour periods of the continuous ingest test must be validated successfully. One test period must use agitation and the other should not.
    - See $ACCUMULO_HOME/test/system/continuous/README for details on running and verifying the continuous ingest test.
  - Two 72-hour periods of continuous ingest must run. One test period must use agitation and the other should not. No validation is necessary but the cluster should be checked to ensure it is still functional.

## Foundation Level Requirements ##

The ASF requires that all artifacts in a release are cryptographically signed and distributed with hashes.

OpenPGP is an asymmetric encryption scheme which lends itself well to the globally distributed nature of Apache.
Verification of a release artifact can be done using the signature and the release-maker's public key. Hashes
can be verified using the appropriate command (e.g. `sha1sum`, `md5sum`).

An Apache release must contain a source-only artifact. This is the official release artifact. While a release of
an Apache project can contain other artifacts that do contain binary files. These non-source artifacts are for
user convenience only, but still must adhere to the same licensing rules.

PMC members should take steps to verify that the source-only artifact does not contain any binary files. There is
some leeway in this rule. For example, test-only binary artifacts (such as test files or jars) are acceptable as long
as they are only used for testing the software and not running it.

The following are the aforementioned Foundation-level documents provided for reference:

* [Applying the Apache Software License][2]
* [Legal's license application guidelines][3]
* [Common legal-discuss mailing list questions/resolutions][4]
* [ASF Legal Affairs Page][5]

## Apache Software License Application ##

Application of the Apache Software License v2 consists of the following steps on each artifact in a release. It's
important to remember that for artifacts that contain other artifacts (e.g. a tarball that contains JAR files or
an RPM which contains JAR files), both the tarball, RPM and JAR files are subject to the following roles.

The difficulty in verifying each artifact is that, often times, each artifact requires a different LICENSE and NOTICE
file. For example, the Accumulo binary tarball must contain appropriate LICENSE and NOTICE files considering the bundled
jar files in `lib/`. The Accumulo source tarball would not contain these same contents in the LICENSE and NOTICE files
as it does not contain those same JARs.

### LICENSE file ###

The LICENSE file should be present at the top-level of the artifact. This file should be explicitly named `LICENSE`,
however `LICENSE.txt` is acceptable but not preferred. This file contains the text of the Apache Software License 
at the top of the file. At the bottom of the file, all other open source licenses _contained in the given
artifact_ must be listed at the bottom of the LICENSE file. Contained components that are licensed with the ASL themselves
do not need to be included in this file. It is common to see inclusions in file such as the MIT License of 3-clause
BSD License.

### NOTICE file ###

The NOTICE file should be present at the top-level of the artifact beside the LICENSE file. This file should be explicitly
name `NOTICE`, while `NOTICE.txt` is also acceptable but not preferred. This file contains the copyright notice for
the artifact being released. As a reminder, the copyright is held by the Apache Software Foundation, not the individual
project.

The second purpose this file serves is to distribute third-party notices from dependent software. Specifically, other code
which is licensed with the ASLv2 may also contain a NOTICE file. If such an artifact which contains a NOTICE file is
contained in artifact being verified for releases, the contents of the contained artifact's NOTICE file should be appended
to this artifact's NOTICE file. For example, Accumulo bundles the Apache Thrift libthrift JAR file which also have its
own NOTICE file. The contents of the Apache Thrift NOTICE file should be included within Accumulo's NOTICE file.

[2]: https://www.apache.org/dev/apply-license
[3]: https://www.apache.org/legal/src-headers
[4]: https://www.apache.org/legal/resolved
[5]: https://www.apache.org/legal
[examples]: https://github.com/apache/accumulo-examples
[semver]: http://semver.org/spec/v2.0.0.html
[at]: https://github.com/apache/accumulo-testing
[at-readme]: https://github.com/apache/accumulo-testing/blob/master/README.md
