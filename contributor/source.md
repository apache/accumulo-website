---
title: Source Code and Developers Guide
skiph1fortitle: true
redirect_from: /source
---

<div class="panel panel-default pull-right">
<div class="panel-heading">Quick Links</div>
<div class="list-group">
<a href="https://gitbox.apache.org/repos/asf?p=accumulo.git;a=summary" class="list-group-item"><i class="fa fa-external-link"></i> Accumulo source</a>
<a href="https://builds.apache.org/job/Accumulo-Master" class="list-group-item"><i class="fa fa-external-link"></i> Master build on Jenkins</a>
<a href="https://issues.apache.org/jira/browse/ACCUMULO" class="list-group-item"><i class="fa fa-external-link"></i> Accumulo JIRA</a>
</div>
</div>


## Developer's Guide

### Building

#### Checking out from Git

To check out the code:

    git clone https://gitbox.apache.org/repos/asf/accumulo.git

#### Running a Build

Accumulo uses  [Apache Maven][maven] to handle source building, testing, and packaging. To build Accumulo, you will need to use Maven version 3.0.5 or later.

You should familiarize yourself with the [Maven Build Lifecycle][lifecycle], as well as the various plugins we use in our [POM][pom], in order to understand how Maven works and how to use the various build options while building Accumulo.

To build from source (for example, to deploy):

    mvn package -Passemble

This will create a file accumulo-*-SNAPSHOT-dist.tar.gz in the assemble/target directory. Optionally, append `-DskipTests` if you want to skip the build tests.

To build your branch before submitting a pull request, you'll probably want to run some basic "sunny-day" integration tests to ensure you haven't made any grave errors, as well as `checkstyle` and `findbugs`:

    mvn verify -Psunny

To run specific unit tests, you can run:

    mvn package -Dtest=MyTest -DfailIfNoTests=false

Or to run the specific integration tests MyIT and YourIT (and skip all unit tests), you can run:

    mvn verify -Dtest=NoSuchTestExists -Dit.test=MyIT,YourIT -DfailIfNoTests=false

There are plenty of other options. For example, you can skip findbugs with `mvn verify -Dfindbugs.skip` or checkstyle `-Dcheckstyle.skip`, or control the number of forks to use while executing tests, `-DforkCount=4`, etc. You should check with specific plugins to see which command-line options are available to control their behavior. Note that not all options will result in a stable build, and options may change over time.

If you regularly switch between major development branches, you may receive errors about improperly licensed files from the [RAT plugin][1]. This is caused by modules that exist in one branch and not the other leaving Maven build files that the RAT plugin no longer understands how to ignore.

The easiest fix is to ensure all of your current changes are stored in git and then cleaning your workspace.

    $> git add path/to/file/that/has/changed
    $> git add path/to/other/file
    $> git clean -df

Note that this git clean command will delete any files unknown to git in a way that is irreversible. You should check that no important files will be included by first looking at the "untracked files" section in a ```git status``` command.

    $> git status
    # On branch master
    nothing to commit (working directory clean)
    $> mvn package
    { maven output elided }
    $> git checkout 1.6.1-SNAPSHOT
    Switched to branch '1.6.1-SNAPSHOT'
    $> git status
    # On branch 1.6.1-SNAPSHOT
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    # mapreduce/
    # shell/
    nothing added to commit but untracked files present (use "git add" to track)
    $> git clean -df
    Removing mapreduce/
    Removing shell/
    $> git status
    # On branch 1.6.1-SNAPSHOT
    nothing to commit (working directory clean)





[16build]: https://builds.apache.org/job/Accumulo-1.6
[17build]: https://builds.apache.org/job/Accumulo-1.7
[1]: https://creadur.apache.org/rat/apache-rat-plugin
[anongit]: git://git.apache.org/accumulo.git
[cgit]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=summary
[contrib]: {{ "/contributor/contrib-projects" | relative_url }}
[devlist]: mailto:dev@accumulo.apache.org
[git-instr]: https://gitbox.apache.org
[git]: https://git-scm.com
[github]: https://github.com/apache/accumulo
[website-repo]: https://github.com/apache/accumulo
[website-readme]: https://github.com/apache/accumulo-website/blob/master/README.md
[hook]: https://gitbox.apache.org/repos/asf?p=accumulo-website.git;a=blob_plain;f=_devtools/git-hooks/post-commit;hb=master
[intellij-formatter]: https://code.google.com/p/eclipse-code-formatter-intellij-plugin
[jekyll]: https://jekyllrb.com
[jenkins]: https://jenkins.io
[jira]: https://www.atlassian.com/software/jira
[jiraloc]: https://issues.apache.org/jira/browse/ACCUMULO
[lifecycle]: https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle
[masterbuild]: https://builds.apache.org/job/Accumulo-Master
[maven]: https://maven.apache.org
[pom]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=blob_plain;f=pom.xml;hb=HEAD
[rb]: {{ "/contributor/rb" | relative_url }}
[site-canon]: https://accumulo.apache.org
[srcheaders]: https://www.apache.org/legal/src-headers
[styles]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=tree;f=contrib;hb=HEAD
