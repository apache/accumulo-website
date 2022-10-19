---
title: Making a Release
redirect_from: 
  - /releasing
  - /contributor/releasing
  - /governance/releasing
---

Follow these steps to make a release of Apache Accumulo.

1. [Setup](#setup)
2. [Triage Issues](#triage-issues)
3. [Create the candidate](#create-the-candidate)
4. [Vote](#vote)
5. [Post release tasks](#post-release-tasks)


## Setup

There are number of things that are required before attempting to build a release.

1. Use gpg-agent, and be sure to increase the gpg-agent cache timeout (via .gnupg/gpg-agent.conf) to ensure that the agent doesn't require re-authentication mid-build, as it will cause things to fail. For example, you can add `default-cache-ttl 6000` to increase the timeout from the default of 10 minutes to over an hour. If you do not have a GPG key, reference the very thorough [ASF release signing documentation][1].
2. Once you are able to sign a release, add your gpg key to the [KEYS file][keys-file] (instructions are at the top of the file).  This will require updating the SVN repository (more information below about the SVN repository). You can use something similar to the instructions below for updating the KEYS file:
   ```
   # install git-svn
   sudo yum install -y git-svn
   # clone the SVN repo into the directory accumulo-dist-gitsvn
   git svn clone https://dist.apache.org/repos/dist/release/accumulo accumulo-dist-gitsvn
   cd accumulo-dist-gitsvn
   # make changes to KEYS file, then commit the changes locally
   git add KEYS
   git commit
   # push the changes to the remote SVN repo
   git svn dcommit --username=<ASF_Username>
   ```
3. Ensure that you're building Apache Accumulo with a username that has the same name as your Apache ID (this is due to
   the maven-release-plugin and staging the release candidate).  Your Apache ID and password should be in a <server> section of ~/.m2/settings.xml as shown [here][apache-mvn].
   To encrypt the password follow these [instructions][maven-enc].
4. Have a clean workspace before starting.
5. The build will require having the same version of [Thrift binary][thrift] installed on your machine. 

Given all of this, it's recommended that you only attempt making a release from a GNU/Linux machine.

## Triage issues.

Before creating a release candidate, all open issues with a fix version of the release candidate should be triaged.

## Create the candidate

**TL;DR**

* `./assemble/build.sh --create-release-candidate` to make the release candidate.
* Verify the artifacts in [ASF Nexus][2] and if valid, close the staging repo.
* Enter the #### of the staging repo when the script prompts to generate the VOTE email.
* `git push upstream x.y.z-rc#` if your git _upstream_ is different from _origin_
* `git push upstream x.y.z-rc#-next` push new branches to the upstream git repo. (script pushes to _origin_)
* Remove any _Expected fingerprints_ generated in the email that do not match your gpg fingerprint.
* Verify email links are valid and email _dev@accumulo.apache.org_ starting the VOTE.
* **[VOTE](#vote)**
* *If vote fails*, fix the original branch and start over.
* *If vote passes*, `git merge x.y.z-rc#-next` back into the original branch you released from.
* Go to the [Post release tasks](#post-release-tasks)

**Explanation of build script**

You should run `assemble/build.sh --create-release-candidate` to create the release candidate. This script is
desirable as it activates all necessary maven profiles in addition to verifying that certain preconditions
are met. If successful, it will also generate a release VOTE email.

When invoking build.sh with the --create-release-candidate option, the majority of the work will be performed
by the maven-release-plugin, invoking *release:clean*, *release:prepare*, and *release:perform*. These will
guide you through choosing the correct versions. The default options provided should be what you choose.
It is highly recommended that an 'RC' suffix is *not* appended to the release version the plugin prompts
you for, as that will result in that version string being placed into the poms, which then would require 
voting to occur on artifacts that cannot be directly promoted. After the build.sh script finishes (this will 
likely take at least 15 minutes, even on recent hardware), your current branch will be on the "next" version 
that you provided to the release plugin.

With a successful invocation of *mvn release:perform*, a staging repository will be made for you on the
[ASF Nexus server][2] which you can log into with your ASF credentials.  The script will prompt for the
generated number at the end of the staging repository name, i.e. 1086 for `orgapacheaccumulo-1086`.

After you log into Nexus, click on _Staging Repositories_ in the _Build Promotion_ toolbar on the left side of
the screen. Assuming your build went according to plan, you should have a new staging repository made for
you. At this point, you should inspect the artifacts that were staged to ensure that they are as you expect
them to be. When you're ready to present those artifacts for voting, you need to close that repository which
will make it publicly available for other members to inspect.

## Vote

At this point, you should have a closed repository that's ready to vote on. Send a message to [the dev
list](mailto:dev@accumulo.apache.org) and get the ball rolling. Developers should test and verify the
release candidate on their own. Accumulo has a guide for [verifying releases][verify].

Lazy consensus is not sufficient for a release; at least 3 +1 votes from PMC members are required. All
checksums and signatures need to be verified before any voter can +1 it. Voting shall last 72 hours. Voters
SHOULD include with their vote details on the tests from the testing section they have successfully run.
If given, said details for each test MUST include: the number of worker nodes in the cluster, the operating system
and version, the Hadoop version, and the Zookeeper version.  For testing done on a version other than the release
candidate that is deemed relevant, include the commit hash. All such gathered testing information will be included
in the release notes.

If the vote ultimately fails, you delete the staged repository, clean up the branch you created (or wait
until the release ultimately passes if you choose), and fix what needs fixing.

If the vote passes, send a draft announcement to the Dev list and once someone reviews it, email the release
announcement.

# Post release Tasks

## Promote the artifacts 

Promote that staged repository using Nexus which you can do with the click of a button. This will trigger
a process to get the release out to all of the mirrors.
In Nexus:
* For example, rc3 passes. Release the X.Y.Z-rc3 staging repository to Maven Central
* Drop old (rc1,rc2) staging repos

## Create the final Git tag

The Git repository should also contain a tag which refers to the final commit which made up a release. This tag
should also be signed with your GPG key. To ensure proper retention on release (stemming from ASF policy
requirements), This final tag *must* being with "rel/". For example, a release of 1.7.0 should have a corresponding
tag name of "rel/1.7.0".

Run the command in the email generated from the `assemble/build.sh` script. It will be something like:
* `git tag -f -m 'Apache Accumulo 1.10.0' -s rel/1.10.0 4d261254`

Then push the signed tag. For example:
* `git push upstream rel/1.10.0`


## Copy artifacts to dist.apache.org

An SVN server is running at https://dist.apache.org/repos/dist/release/accumulo. You need to upload the release
tarballs, the GPG signatures and checksum files to the correct directory (based on the release number). If you
are releasing a bug-fix release, be sure to delete the previous release in the same line (e.g. if you release
1.6.2, remove 1.6.1). The old tarballs removed from dist.apache.org will still be preserved in archive.apache.org
automatically.

## Update projects.apache.org

Fill out the [add release][addrelease] form to update the projects website.

## Update the Accumulo project website

After a successful vote, [this website][website-repo] needs to be updated with the new artifacts.

  * Update downloads page
  * Create a post in `_posts/release/` containing release notes
  * Remove previous bug-fix release (if applicable)
  * Update doap/accumulo.rdf
  * Complete release notes
  * Update previous release notes (as archived or archived-critical)
  * Update `_config.yml`
  * Update `_includes/nav.html`

## Update Documentation

Starting with 2.0.0, the source code for the Accumulo documentation was moved to the [accumulo-website repo][website-repo] except
for two markdown files that should be changed in the Accumulo repo and copied/mirrored to the website repo for releases.

1. `server-properties.md` and `client-properties.md` should be copied after it is generated by the Accumulo build.

        cp /path/to/accumulo/core/target/generated-docs/*-properties.md /path/to/accumulo-website/_docs-2-x/configuration/

**For major releases,** follow the steps below to create docs for next release:

1. Create a new documentation collection for the new major release (i.e `3.x`) using the collection of the last release. Avoid using a dot `.` in
   the directory name:

        cp -r _docs-2 _docs-3

2. Create a new doc layout using the previous layout. Update the reference to `site.docs-2` to `site.docs-3` (if creating 3.x docs):

        cp _layouts/docs-3.html _layouts/docs-3.html
        vim _layouts/docs-3.html

3. Point Jekyll to the new documentation collection by modifying `collections` and `defaults` in `_config.yml`. Follow what was done for previous
   releases.

4. Copy `server-properties.md` and `client-properties.md`, and mirror `INSTALL.md`.

Once a collection is created for a major release, developers can make documentation updates like normal website updates.

**For 2.x minor & bugfix releases,** copy `server-properties.md` and `client-properties.md`, and mirror `INSTALL.md`.

**For 1.x minor & bugfix releases,** copy `accumulo_user_manual.html` generated for release to the `1.x/` directory in the [accumulo-website repo][website-repo].

## Update Javadocs

Javadocs are easy to update. Using the latest JDK8 or later, follow these steps:

1. Unpack the source release tarball and change to its root directory, or checkout the SCM tag for the release
2. Build the javadocs with `mvn clean package javadoc:aggregate -DskipTests -Paggregate-javadocs`
3. Take note that the javadocs you will need to copy are the entire contents of `./target/site/apidocs/`
4. In a different directory, checkout the `main` branch of the accumulo-website repo
5. Remove any existing apidocs from the appropriate version folder (e.g. 1.6/apidocs for a 1.6.x release)
6. Copy the entire contents of the new apidocs directory (identified in step 3) to the destination in the website branch (e.g. to 1.6/apidocs)
7. Continue updating the site content, as needed
8. Commit the changes
9. Update the site using jekyll with `./_devtools/git-hooks/post-commit` (if you don't have the commit hook already configured)
10. Don't forget to push both the `main` and `asf-site` branches back to the accumulo-website repo
11. Verify that javadocs have been updated on the production site (e.g. https://accumulo.apache.org/1.6/apidocs/)

## Update Accumulo Examples

After the release has been made, the Accumulo version used by [Accumulo Examples][examples] should be updated
if this is the latest release of Accumulo.

 * Update the `accumulo.version` property in `pom.xml` of accumulo-examples
 * Run `mvn clean verify` to confirm that nothing breaks
 * Run one of the examples for additional testing.

## References

- [Publishing Maven Artifacts][apache-mvn]
- [Publishing Releases][apache-release]

[1]: https://infra.apache.org/release-signing
[2]: https://repository.apache.org/#stagingRepositories
[apache-release]: https://infra.apache.org/release-publishing
[addrelease]: https://reporter.apache.org/addrelease?accumulo
[verify]: {{ "/contributor/verifying-release" | relative_url }}
[examples]: https://github.com/apache/accumulo-examples
[website-repo]: https://github.com/apache/accumulo-website
[keys-file]: https://downloads.apache.org/accumulo/KEYS
[apache-mvn]: https://infra.apache.org/publishing-maven-artifacts.html
[maven-enc]: https://maven.apache.org/guides/mini/guide-encryption.html
[thrift]: http://archive.apache.org/dist/thrift/
