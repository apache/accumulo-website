---
title: How To Contribute
permalink: /how-to-contribute/
redirect_from: /contributor/
---

Contributions are welcome to all Apache Accumulo repositories. While most contributions are code,
there are other ways to contribute to Accumulo:

* answer questions on [mailing lists](/contact-us/#mailing-lists)
* review [pull requests](https://github.com/apache/accumulo/pulls)
* verify and test new [releases](/release/)
* update the [Accumulo website and documentation](https://github.com/apache/accumulo-website)

Contributions are reviewed (via GitHub pull requests) by
the community before being merged by a committer.

This document provides basic instructions for contributing to Accumulo.  If you are looking for more information, check out the more comprehensive [contributor guide](/contributors-guide/).

## Issues

Accumulo uses GitHub issues to track bugs and features.  Each git repository
has its own issues.  In GitHub pull request are issues, therefore creating an
issue before a pull request is optional. If unsure whether to start with an
issue or pull request, then create an issue. If you need help finding an issue
to work on, check out the [open issues labeled 'helpwanted'][helpwanted] or
[contact us][contact].

Accumulo previously used [JIRA], but is now transitioning to GitHub issues.
All new issues should be opened using GitHub. When working an existing JIRA
issue, please do the following :

 * Open a new GitHub issue or pull request.
 * Link the GitHub issue to the JIRA issue.
 * Link the JIRA issue to the GitHub issue.
 * Close the JIRA issue as a duplicate.

Eventually JIRA will be transitioned to a read-only state for reference.  For
finding issues to work, there may still be 
[open issues labeled for newbies][newbie-issues] in JIRA.

## Labels

Labels, such as `bug`, `enhancement`, and `duplicate`, are used to
descriptively organize issues and pull requests. Issues labeled with `blocker`
indicate that the developers have determined that the issue must be fixed prior
to a release (to be used in conjunction with a version-specific project board;
see the next section for information on project boards).

Currently only Accumulo committers can set labels.  If you think a label should
be set, comment on the issue and someone will help.

## Project Boards (Projects)

Project boards (also "projects") are used to track the status of issues and
pull requests for a specific milestone. Projects with names such as `2.1.0`,
and `1.9.2` are used for tracking issues associated with a particular release
and release planning. These are set up as basic Kanban boards with automation,
with `To do`, `In progress`, and `Done` statuses. These projects are marked as
"closed" when the version indicated is released. Other projects may exist for
miscellaneous puposes, such as tracking multiple issues related to a larger
effort. These projects will be named appropriate to indicate their purpose.

Committers manage the project boards. If you need help with a project board or
have questions, contact the developers using the link at the top of this page.

## Repositories

Contributions can be made to the following repositories. While the general contribution workflow is
described below, repositories have special instructions in their `CONTRIBUTING.md` file which can be
viewed by clicking on `contribute` in the Links column below.

| Repository                      | Links                         | Description
| ------------------------------- | ----------------------------- | -----------
| [Accumulo][a]                   | [Contribute][ac] [Issues][ai]  | Core Project
| [Accumulo Website][w]           | [Contribute][wc] [Issues][wi]  | Source for this website
| [Accumulo Examples][e]          | [Contribute][ec] [Issues][ei]  | Accumulo example code
| [Accumulo Testing][t]           | [Contribute][tc] [Issues][ti]  | Accumulo test suites such as continuous ingest and random walk
| [Accumulo Docker][d]            | [Contribute][dc] [Issues][di]  | Source for Accumulo Docker image
| [Accumulo Wikisearch][s]        | [Contribute][sc] [Issues][si]  | Accumulo example application that indexes and queries Wikipedia data

## Contribution workflow

1. Create a [GitHub account][github-join] for issues and pull requests.
1. Find an [issue][helpwanted] to work on or optionally create one that describes the work that you want to do.
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
* Accumulo follows [semver] for its [public API](/api/).
* Every file requires the ASF license header as described in [ASF Source Header][srcheaders].
* Remove all trailing whitespaces. Eclipse users can use Source&rarr;Cleanup option to accomplish this.
* Use 2 space indents and never use tabs!
* Use 100-column line width for Java code and Javadoc.
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

* **Build resources** - [TravisCI] & [Jenkins][jenkins]
* **Releases** - [Making a release][making], [Verifying a release][verifying]

For more details, see the [contributor guide](/contributors-guide/).

[newbie-issues]: https://s.apache.org/newbie_accumulo_tickets
[helpwanted]: https://github.com/search?utf8=%E2%9C%93&q=state%3Aopen+label%3A%22help+wanted%22+repo%3Aapache%2Faccumulo+repo%3Aapache%2Faccumulo-website+repo%3Aapache%2Faccumulo-examples+repo%3Aapache%2Faccumulo-testing&type=
[contact]: /contact-us/
[a]: https://github.com/apache/accumulo
[ac]: https://github.com/apache/accumulo/blob/master/CONTRIBUTING.md
[ai]: https://github.com/apache/accumulo/issues
[w]: https://github.com/apache/accumulo-website
[wc]: https://github.com/apache/accumulo-website/blob/master/CONTRIBUTING.md
[wi]: https://github.com/apache/accumulo-website/issues
[e]: https://github.com/apache/accumulo-examples
[ec]: https://github.com/apache/accumulo-examples/blob/master/CONTRIBUTING.md
[ei]: https://github.com/apache/accumulo-examples/issues
[t]: https://github.com/apache/accumulo-testing
[tc]: https://github.com/apache/accumulo-testing/blob/master/CONTRIBUTING.md
[ti]: https://github.com/apache/accumulo-testing/issues
[d]: https://github.com/apache/accumulo-docker
[dc]: https://github.com/apache/accumulo-docker/blob/master/CONTRIBUTING.md
[di]: https://github.com/apache/accumulo-docker/issues
[s]: https://github.com/apache/accumulo-wikisearch
[sc]: https://github.com/apache/accumulo-wikisearch/blob/master/CONTRIBUTING.md
[si]: https://github.com/apache/accumulo-wikisearch/issues
[jira-signup]: https://issues.apache.org/jira/secure/Signup!default.jspa
[github-join]: https://github.com/join
[manual]: {{ site.docs_baseurl }}
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
