---
title: Contributor Guide
---

This page contains resources and documentation of interest to current or potential contributors to the Accumulo project. Any documentation that is helpful to Accumulo users should go in the [Accumulo User Manual][manual].

If your are interested in quickly getting an Accumulo instance up and running, see the [Accumulo Quickstart][quickstart] guide or refer to the [Uno] project on Github.

- [How to contribute to Apache Accumulo](./#how-to-contribute-to-apache-accumulo)
- [Source Code](./#source-code)
- [Issue Tracking](./#issue-tracking)
- [Automated Build Information](./#automated-build-information)
- [Create a ticket for new bugs or feature](./#creating-a-ticket-for-bugs-or-new-features)
- [Building Accumulo from Source](./#building-accumulo-from-source)
  - [Configuring Your Git Client](./#configuring-your-git-client)
  - [Cloning the Accumulo repository](./#cloning-the-accumulo-repository)
    - [From the Apache Hosted Repository](./#from-the-apache-hosted-repository)
    - [From the Github mirror](./#from-the-github-mirror)
    - [From your Github fork](./#from-your-github-fork)
      - [Retrieval of upstream changes](./#retrieval-of-upstream-changes)
  - [Supplying a contribution](./#)
    - [Supplying a contribution through patch and JIRA issue](./#)
    - [Supplying a contribution through a pull Request(PR) via Github](./#)
      - [Pushing changes to your personal, Github repository](./#)
      - [Opening a Pull Request(PR) to the Accumulo project](./#)
- [Code review process](./#code-review-process)
- [Additional Contributor Information](./#additional-contributor-information)
  - [Installing Apache Thrift](./#installing-apache-thrift)
  - [Accumulo Website Contributions](./#project-website)   
- Additional Developer Documentation
  - [Merging Practices](./merging-practices)
  - [Public API](/#public-api)
  - [Coding Practices](./#coding-practices)
  - [Versioning Information](./versioning)
  - [Contrib Projects](./contrib-projects)
  - [Review Board](./rb)
- Release Guides
  - [Making a Release](./making-release)
  - [Verifying a Release](./verifying-release)
- Project Governance
  - [Bylaws](./bylaws)
  - [Consensus Building](./consensusBuilding)
  - [Lazy Consensus](./lazyConsensus)
  - [Voting](./voting)
- [IDE Configuration Tips](./#ide-configuration-tips)
  - [Eclipse](./#eclipse)
  - [IntelliJ](./#intellij)


## How to Contribute to Apache Accumulo

Apache Accumulo welcomes contributions from the community. This is especially true of new contributors! You don’t need to be a software developer to contribute to Apache Accumulo. To be successful, this project requires a huge range of different skills, levels of involvement, and degrees of technical expertise. So, if you want to get involved in Apache Accumulo, there is almost certainly a role for you. View our [Get Involved](../get_involved) page for additional details on the many opportunities available.

## Source Code

Apache Accumulo&reg; source code is maintained using [Git] version control and mirrored to [GitHub]. Source files can be browsed [here][browse] or at the [GitHub mirror][mirror]. 

The project code can be checked-out [here][mirror]. It builds with [Apache Maven][maven].

### Issue Tracking

Accumulo [tracks issues][jiraloc] with [JIRA][jira].  Every commit should reference a JIRA ticket of the form ACCUMULO-#.

### Continuous Integration

Accumulo uses [Jenkins][jenkins] and [TravisCI](https://travis-ci.org/apache/accumulo) for automatic builds.

<img src="https://builds.apache.org/job/Accumulo-Master/lastBuild/buildStatus" style="height: 1.1em"> [Master][masterbuild]

<img src="https://builds.apache.org/job/Accumulo-1.8/lastBuild/buildStatus" style="height: 1.1em"> [1.8 Branch][18build]

<img src="https://builds.apache.org/job/Accumulo-1.7/lastBuild/buildStatus" style="height: 1.1em"> [1.7 Branch][17build]

## Creating a Ticket for Bugs or New features

If you run into a bug or think there is something that would benefit the project, we encourage you to file an issue at the [Apache Accumulo JIRA][jiraloc] page. Regardless of whether you have the time to provide the fix or implementation yourself, this will be helpful to the project.



## Building Accumulo From Source

### Configuring your Git Client

### Cloning the Accumulo Repository

#### From the Apache Hosted Repository

#### From the Github mirror

#### From your Github fork

##### Retrieval of upstream changes




### Checking out the 'master' or '1.x' branch

## Providing a Contribution

### Understanding the Giflow development model

### Performing your code changes

#### Creating a feature branch

### Testing your changes

### Updating Licensing Documentation

### Commiting your changes

#### Staging file(s) to be committed

#### Performing the commit
  
### Keeping your feature branch current

#### Updating your local copy of master

#### Performing a git rebase from your branch



### Supplying a Contribution

#### Supplying a contribution through patch and JIRA issue

#### Supplying a contribution through a pull Request(PR) via Github

##### Pushing changes to your personal, Github repository

##### Opening a Pull Request(PR) to the Accumulo project



## Code review process

Accumulo primarily used GitHub (via pull requests) for code reviews, but has access to an instance of [Review Board](https://reviews.apache.org/) as well if that is preferred.

Accumulo operates under the [Commit-Then-Review](https://www.apache.org/foundation/glossary#CommitThenReview) (CtR) policy, so a code review does not need to occur prior to commit. However, a commiter has the option to hold a code review before a commit happens if, in their opinion, it would benifit from additional attention. Full details of the code review process for Accumulo is documented [here](./rb)

## Additional Contributor Information

### Merging Practices

Changes should be merged from earlier branches of Accumulo to later branches. Ask the [dev list](dev@accumulo.apache.org) for instructions.

### Public API

Refer to the README in the release you are using to see what packages are in the public API.

Changes to non-private members of those classes are subject to additional scrutiny to minimize compatibility problems across Accumulo versions.

### Coding Practices

{: .table}
| **License Header**              | Always add the current ASF license header as described in [ASF Source Header][srcheaders].            |
| **Trailing Whitespaces**        | Remove all trailing whitespaces. Eclipse users can use Source&rarr;Cleanup option to accomplish this. |
| **Indentation**                 | Use 2 space indents and never use tabs!                                                               |
| **Line Wrapping**               | Use 160-column line width for Java code and Javadoc.                                                  |
| **Control Structure New Lines** | Use a new line with single statement if/else blocks.                                                  |
| **Author Tags**                 | Do not use Author Tags. The code is developed and owned by the community.   

### Installing Apache Thrift

If you activate the ‘thrift’ Maven profile, the build of some modules will attempt to run the Apache Thrift command line to regenerate stubs. If you activate this profile and don’t have Apache Thrift installed and in your path, you will see a warning and your build will fail. For Accumulo 1.5.0 and greater, install Thrift 0.9 and make sure that the ‘thrift’ command is in your path. Watch out for THRIFT-1367; you may need to configure Thrift with –without-ruby. Most developers do not need to install or modify the Thrift definitions as a part of developing against Apache Accumulo.
Checking out from Git

### Project Website

The source for this website is a collection of markdown documents that are converted to HTML using
[Jekyll]. It can be found in the [accumulo-website repo][website-repo]. If you would like to make changes to
this website, clone the website repo and edit the markdown:

```
    git clone https://github.com/apache/accumulo-website.git
```

After you have made your changes, follow the instructions in the [README.md][website-readme] to run the website
locally and make a pull request on [GitHub][website-repo]. If you have problems installing Jekyll or running the
website locally, it's OK to proceed with the pull request. A committer will review your changes before committing
them and updating the website.

## IDE Configuration Tips

### Eclipse

* Download Eclipse [formatting and style guides for Accumulo][styles].
* Import Formatter: Preferences > Java > Code Style >  Formatter and import the Eclipse-Accumulo-Codestyle.xml downloaded in the previous step. 
* Import Template: Preferences > Java > Code Style > Code Templates and import the Eclipse-Accumulo-Template.xml. Make sure to check the "Automatically add comments" box. This template adds the ASF header and so on for new code.

### IntelliJ

 * Formatter [plugin][intellij-formatter] that uses eclipse code style xml.



[jenkins]: https://jenkins.io
[manual]: {{ site.baseurl }}/{{ site.latest_minor_release }}/accumulo_user_manual.html
[Git]: https://git-scm.com/
[browse]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=summary
[quickstart]: {{ site.baseurl }}/quickstart-1.x/
[Uno]: https://github.com/astralway/uno
[GitHub]: https://www.github.com/
[maven]: https://maven.apache.org/
[mirror]: https://github.com/apache/accumulo
[jekyll]: https://jekyllrb.com
[jira]: https://www.atlassian.com/software/jira
[jiraloc]: https://issues.apache.org/jira/browse/ACCUMULO
[masterbuild]: https://builds.apache.org/job/Accumulo-Master
[18build]: https://builds.apache.org/job/Accumulo-1.8
[17build]: https://builds.apache.org/job/Accumulo-1.7
[website-readme]: https://github.com/apache/accumulo-website/blob/master/README.md
[website-repo]: https://github.com/apache/accumulo
[intellij-formatter]: https://code.google.com/p/eclipse-code-formatter-intellij-plugin
[styles]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=tree;f=contrib;hb=HEAD
[jiraloc]: https://issues.apache.org/jira/browse/ACCUMULO


