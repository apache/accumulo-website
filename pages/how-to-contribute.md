---
title: How To Contribute
permalink: /how-to-contribute/
redirect_from: /contributor/
---

Contributions are welcome to all Apache Accumulo repositories. While most contributions are code,
there are other ways to contribute to Accumulo:

* answer questions on mailing lists
* review pull requests
* verify and test new releases
* update the Accumulo website and documentation

Contributions are reviewed (via GitHub pull requests) by
the community before being merged by a committer.

This document provides basic instructions for contributing to Accumulo.  If you are looking for more information, check out the more comprehensive [contributor guide](/contributors-guide/).

## Issues

Any contribution should have a corresponding issue. Accumulo uses [JIRA] for issue tracking. Before creating an issue,
you will need to create an [Apache JIRA account][jira-signup]. If you need help finding an issue to work on, check out
the [open issues labeled for newbies][newbie-issues] or [contact us][contact].

## Repositories

Contributions can be made to the following repositories. While the general contribution workflow is
described below, repositories have special instructions in their `CONTRIBUTING.md` file which can be
viewed by clicking on `contribute` in the Links column below.

| Repository                      | Links    | Description
| ------------------------------- | -------- | -----------
| [Accumulo][a]                   | [contribute][ac]  | Core Project
| [Accumulo Website][w]           | [contribute][wc]  | Source for this website
| [Accumulo Examples][e]          | [contribute][ec]  | Accumulo example code
| [Accumulo Testing][t]           | [contribute][tc]  | Accumulo test suites such as continuous ingest and random walk
| [Accumulo Docker][d]            | [contribute][dc]  | Source for Accumulo Docker image
| [Accumulo Wikisearch][s]        | [contribute][sc]  | Accumulo example application that indexes and queries Wikipedia data

## Contribution workflow

1. Create an [Apache JIRA account][jira-signup] (for issue tracking) and [GitHub account][github-join] (for pull requests).
1. Find an [issue][newbie-issues] to work on or create one that describes the work that you want to do.
1. [Fork] and [clone] the GitHub repository that you want to contribute to.
1. Create a branch in the local clone of your fork.
```    
    git checkout -b accumulo-4321
```    
1. Do work and commit to your branch. You can reference [this link][messages] for a guide on how to write good commit log messages.
1. Ensure you works satisfies the guidelines laid out in the `CONTRIBUTING.md` file.
1. If needed, squash to the minimum number of commits. For help on squashing commits, see this [tutorial][squash-tutorial] or [StackOverflow answer][squash-stack].
1. [Push] your branch to your fork.
```
    git push origin accumulo-4321
```
1. Create a [Pull Request] on GitHub to the appropriate repository. If the work is not complete and the Pull Request is for feedback, please put `[WIP]` in the subject.
1. At least one committer (and others in the community) will review your pull request and add any comments to your code.
1. Push any changes from the review to the branch as new commits so the reviewer only needs to review new changes. Please avoid squashing commits after the review starts. Squashing makes it hard for the reviewer to follow the changes.
1. Repeat this process until a reviewer approves the pull request.
1. When the review process is finished, all commits on the pull request may be squashed by a committer. Please avoid squashing as it makes it difficult for the committer to know if they are merging what was reviewed.

## Coding Guidelines

* If a change needs to go into multiple branches of Accumulo, it should be merged into earlier branches then later branches. 
* Accumulo follows [semver] for its public API. Accumulo lists which packages are public API in its [README.md][accumulo-readme]. 
* Every file requires the ASF license header as described in [ASF Source Header][srcheaders].
* Remove all trailing whitespaces. Eclipse users can use Source&rarr;Cleanup option to accomplish this.
* Use 2 space indents and never use tabs!
* Use 160-column line width for Java code and Javadoc.
* Use a new line with single statement if/else blocks.
* Do not use Author Tags. The code is developed and owned by the community.

## Code Editors

Feel free to use any editor when contributing Accumulo. If you are looking for a recommendation, many Accumulo
developers use [IntelliJ][intellij] or [Eclipse][eclipse]. Below are some basic instructions to help you get started.

### IntelliJ

1. Download and install [IntelliJ][intellij]
1. Clone the Accumulo repository that you want to work on.
   ```shell
   git clone https://github.com/apache/accumulo.git
   ```
1. [Import][intellij-import] the repository as a Maven project into IntelliJ
1. (Optional) Download and import `Eclipse-Accumulo-Codestyle.xml` from Accumulo's [contrib][accumulo-contrib] directory
  * Import via `File` > `Settings` > `Code Style` and clicking on cog wheel

### Eclipse

1. Download and install [Eclipse][eclipse].
1. Clone the Accumulo repository that you want to work on.
   ```shell
   git clone https://github.com/apache/accumulo.git
   ```
1. [Import][eclipse-import] the repository as a Maven project into Eclipse
1. (Optional) Download and import Eclipse formatting and style guides from Accumulo's [contrib][accumulo-contrib] directory
  * Import Formatter: `Preferences` > `Java` > `Code Style` > `Formatter` and import the `Eclipse-Accumulo-Codestyle.xml` downloaded in the previous step. 
  * Import Template: `Preferences` > `Java` > `Code Style` > `Code Templates` and import the `Eclipse-Accumulo-Template.xml`. Make sure to check the "Automatically add comments" box. This template adds the ASF header and so on for new code.

## Helpful Links

* **Build resources** - [TravisCI] & [Jenkins][jenkins] ([Master][masterbuild], [1.8 Branch][18build], [1.7 Branch][17build])
* **Releases** - [Making a release][making], [Verifying a release][verifying]

For more details, see the [contributor guide](/contributors-guide/).

[newbie-issues]: https://s.apache.org/newbie_accumulo_tickets
[contact]: /contact-us/
[a]: https://github.com/apache/accumulo
[ac]: https://github.com/apache/accumulo/blob/master/CONTRIBUTING.md
[w]: https://github.com/apache/accumulo-website
[wc]: https://github.com/apache/accumulo-website/blob/master/CONTRIBUTING.md
[e]: https://github.com/apache/accumulo-examples
[ec]: https://github.com/apache/accumulo-examples/blob/master/CONTRIBUTING.md
[t]: https://github.com/apache/accumulo-testing
[tc]: https://github.com/apache/accumulo-testing/blob/master/CONTRIBUTING.md
[d]: https://github.com/apache/accumulo-docker
[dc]: https://github.com/apache/accumulo-docker/blob/master/CONTRIBUTING.md
[s]: https://github.com/apache/accumulo-wikisearch
[sc]: https://github.com/apache/accumulo-wikisearch/blob/master/CONTRIBUTING.md
[jira-signup]: https://issues.apache.org/jira/secure/Signup!default.jspa
[github-join]: https://github.com/join
[manual]: {{ site.baseurl }}/{{ site.latest_minor_release }}/accumulo_user_manual.html
[JIRA]: https://issues.apache.org/jira/browse/ACCUMULO
[GitHub]: https://github.com/apache/accumulo/pulls
[Jenkins]: https://builds.apache.org/view/A/view/Accumulo
[TravisCI]: https://travis-ci.org/apache/accumulo
[making]: {{ "/contributor/making-release" | relative_url }}
[verifying]: {{ "/contributor/verifying-release" | relative_url }}
[Fork]: https://help.github.com/articles/fork-a-repo/
[Pull Request]: https://help.github.com/articles/about-pull-requests/
[Push]: https://help.github.com/articles/pushing-to-a-remote/
[clone]: https://help.github.com/articles/cloning-a-repository/
[masterbuild]: https://builds.apache.org/job/Accumulo-Master
[18build]: https://builds.apache.org/job/Accumulo-1.8
[17build]: https://builds.apache.org/job/Accumulo-1.7
[srcheaders]: https://www.apache.org/legal/src-headers
[styles]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=tree;f=contrib;hb=HEAD
[accumulo-readme]: https://github.com/apache/accumulo/blob/master/README.md#api
[semver]: http://semver.org/spec/v2.0.0.html
[eclipse]: https://www.eclipse.org/
[eclipse-import]: https://stackoverflow.com/questions/2061094/importing-maven-project-into-eclipse
[intellij]: https://www.jetbrains.com/idea/
[intellij-import]: https://www.jetbrains.com/help/idea/maven.html#maven_import_project_start
[accumulo-contrib]: https://github.com/apache/accumulo/tree/master/contrib
[messages]: https://chris.beams.io/posts/git-commit/
[squash-tutorial]: http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html
[squash-stack]: https://stackoverflow.com/questions/5189560/squash-my-last-x-commits-together-using-git
