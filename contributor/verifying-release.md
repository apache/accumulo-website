---
title: Verifying a Release
redirect_from: /verifying_releases
---

This is a guide to help verify the quality of a release or release candidate. The testing described
here is not a requirement of the Foundation, but may be useful to help PMC members decide how they
wish to vote for a release candidate.

## Versioning

Accumulo has adopted [Semantic Versioning][semver] and follows their rules and guidelines.

## Testing basics

Each release of Accumulo should be tested by the community to verify correctness.

Below are some suggested tests that can be run (feel free to run your own custom tests too):

* Run only Accumulo's unit tests and build the software using `mvn package`
* Run Accumulo's unit and integration tests using `mvn verify`
* Build the [Accumulo Examples][examples] repo using the release candidate by updating the
  `accumulo.version` property in the `pom.xml` and using the staging repo. Also, run the
  unit/integration tests using `mvn verify`.
* Run Accumulo's distributed tests (i.e. random walk, continuous ingest). These tests are intended
  to be run for hours or days, optionally injecting faults into the system through "agitation".
  These tests simulate behaviors that can occur on a real deployment. Starting with 2.0, these tests
  are run using the [Accumulo Testing repo][at]. See the [README.md][at-readme] for more
  information. Before 2.0, these tests are found in Accumulo tarball at `test/system/randomwalk` and
  `test/system/continuous` which include instructions on how to run the tests.

## Project testing goals

While contributors do not need perform all tests, there should a minimum amount of testing done by
the project as whole before a release. The testing that the developers do are documented in the
release notes for that release.

Testing for an Accumulo release includes a few steps that a developer may take without a Hadoop
cluster and several that require a working cluster. For minor releases, the tests which run on a
Hadoop cluster are recommended to be completed but are not required. Running even a reduced set of
tests against real hardware is always encouraged even if the full test suite (in breadth of nodes or
duration) is not executed. New major releases are expected to receive more comprehensive testing,
because they contain a greater number of changes and require more vetting.

If PMC members do not believe adequate testing was performed for the sake of making the proposed
release, they may vote `-0` or `-1` on that release and are encouraged to assist with testing the
release to their satisfaction.

### Stand alone

The following steps can be taken without having an underlying cluster. They should be handled with
each Hadoop profile available for a given release version. To activate an alternative profile
specify e.g. `-Dhadoop.profile=2` for the Hadoop 2 profile on the Maven commandline. Some older
versions of Accumulo referred to Hadoop profiles differently; see the README that came with said
versions for details on building against different Hadoop versions, or its release notes.

  - All JUnit tests should pass. This should be a requirement of any patch so it should never be an
    issue during a release.
    - Use `mvn package` to run against the default profile of a particular release
    - Use `mvn -Dhadoop.profile=2 package` to test against the Hadoop 2 profile (not applicable to
      all versions)
  - Analyze output of static analysis tools like spotbugs and PMD.
  - For versions 1.6 and later, all integration tests should pass via the Maven failsafe plugin.
    - Use `mvn verify` to run against the default profile of a particular release
    - Use `mvn -Dhadoop.profile=2 verify` to run the tests against the Hadoop 2 profile (not
      applicable to all versions)

### Cluster based

The following tests require a Hadoop cluster running a minimum of HDFS, MapReduce, and ZooKeeper.
The cluster may have any number of worker nodes; it can even be a single node in pseudo-distributed
mode. A cluster with multiple tablet servers should be used so that more of the code base will be
exercised. For the purposes of release testing, you should note the number of nodes and versions
used. See the Releasing section for more details. These are only example of cluster tests. You may
run more or less tests. Information about these can be found in the [Accumulo Testing repo][at].

  - Two 24-hour periods of the `LongClean` module of the RandomWalk test without unexpected errors,
    one with agitation, and one without
  - Two 24-hour periods of the continuous ingest test, with successful verification, one with
    agitation and one without
  - A 24-hour period of the bulk continuous ingest test, with successful verification
  - A 72-hour period of continuous ingest without verification, but check the logs for any errors
    and ensure the cluster is still functional

## Foundation Level Requirements ##

The ASF requires that all artifacts in a release are cryptographically signed and distributed with
hashes.

PGP/GPG is an asymmetric encryption scheme which lends itself well to the globally distributed
nature of Apache. Verification of a release artifact can be done using the signature and the
release-maker's public key (e.g. `gpg --import KEYS; gpg --verify *.asc`). Hashes can be verified
using the appropriate command (e.g. `sha512sum -c *.sha512`)

An Apache release must contain a source-only artifact. This is the official release artifact. While
a release of an Apache project can contain other artifacts that do contain binary files. These
non-source artifacts are for user convenience only, but still must adhere to the same licensing
rules.

PMC members should take steps to verify that the source-only artifact does not contain any binary
files. There is some leeway in this rule. For example, test-only binary artifacts (such as test
files or jars) are acceptable as long as they are only used for testing the software and not running
it.

The following are the aforementioned Foundation-level documents provided for reference:

* [Applying the Apache Software License][2]
* [Legal's license application guidelines][3]
* [Common legal-discuss mailing list questions/resolutions][4]
* [ASF Legal Affairs Page][5]

## Apache Software License Application ##

Application of the Apache Software License v2 consists of the following steps on each artifact in a
release. It's important to remember that for artifacts that contain other artifacts (e.g. a tarball
that contains JAR files), both the tarball and JAR files are subject to the following rules.

The difficulty in verifying each artifact is that, often times, each artifact requires a different
LICENSE and NOTICE file. For example, the Accumulo binary tarball must contain appropriate LICENSE
and NOTICE files considering the bundled jar files in `lib/`. The Accumulo source tarball would not
contain these same contents in the LICENSE and NOTICE files as it does not contain those same JARs.

### LICENSE file ###

The LICENSE file should be present at the top-level of the artifact. This file should be explicitly
named `LICENSE`. This file contains the text of the Apache Software License at the top of the file.
At the bottom of the file, all other open source licenses _contained in the given artifact_ must be
listed at the bottom of the LICENSE file. Contained components that are licensed with the ASL
themselves do not need to be included in this file. It is common to see inclusions in file such as
the MIT License of 3-clause BSD License.

### NOTICE file ###

The NOTICE file should be present at the top-level of the artifact beside the LICENSE file. This
file should be explicitly named `NOTICE`. This file contains the copyright notice for the artifact
being released. As a reminder, the copyright is held by the Apache Software Foundation, not the
individual project.

The purpose this file serves is to distribute required third-party copyright notices from dependent
software. Specifically, other code which is licensed with the ASLv2 may also contain a NOTICE file.
If such an artifact which contains a NOTICE file is contained in artifact being verified for
releases, the contents of the contained artifact's NOTICE file should be appended to this artifact's
NOTICE file. For example, Accumulo bundles the Apache Thrift libthrift JAR file which also have its
own NOTICE file. The required contents of the Apache Thrift NOTICE file should be included within
Accumulo's NOTICE file. Redundant notices, such as duplicate entries for the Apache Software
Foundation should be omitted. This file should only contain required notices, and nothing else.

[2]: https://www.apache.org/dev/apply-license
[3]: https://www.apache.org/legal/src-headers
[4]: https://www.apache.org/legal/resolved
[5]: https://www.apache.org/legal
[examples]: https://github.com/apache/accumulo-examples
[semver]: https://semver.org/spec/v2.0.0.html
[at]: https://github.com/apache/accumulo-testing
[at-readme]: https://github.com/apache/accumulo-testing/blob/main/README.md
