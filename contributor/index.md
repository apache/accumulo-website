---
title: Contributor Guide
---

This page contains resources and documentation of interest to current and potential contributors to the Accumulo project. Any documentation that is helpful to Accumulo users should go in the [Accumulo User Manual][manual].

If your are interested in quickly getting an Accumulo instance up and running, see the Accumulo Quickstart guides [(1.x)][quickstart1x]/[(2.x)][quickstart2x] or refer to the [Uno] project on Github.

- [How to contribute to Apache Accumulo][1]
- [Project Resources][2]
  - [GitHub][3]
  - [JIRA][4]
  - [Jenkins/TravisCI][5]
- [Create a Ticket for Bugs or New Features][6]
- [Building Accumulo from Source][7]
  - [Checking out from Git][8]
  - [Running a Build][9]
- [Providing a contribution][10]
  - [Proposed Workflow][11]
  - [The Implementation][12]
    - [Contributors][13]
    - [Developers][14]
      - [Primary Development][15]
      - [Reviewing Contributor Changes][16]
      - [Submit Contribution via Patch][17]
      - [Submit Contribution via Pull Request][18]
      - [Feature Branches][19]
      - [Changes Which Affect Multiple-Versions (a.k.a Merging)][20]
- [Code Review Process][21]
- [Additional Contributor Information][22]
  - [Coding Practices][25]
  - [Merging Practices][23]
  - [Project Examples][26]
  - [Website Contributions][27]
  - [Public API][24]
  - [Installing Apache Thrift][29]
  - [Contrib Projects][28]
- [Committer Documentation][32]
- [Project Governance][33]
- [IDE Configuration Tips][34]
- [Contact Us][35]


## How to Contribute to Apache Accumulo

Apache Accumulo welcomes contributions from the community. This is especially true of new contributors! You don’t need to be a software developer to contribute to Apache Accumulo. So, if you want to get involved in Apache Accumulo, there is almost certainly a role for you. View our [Get Involved][get-involved] page for additional details on the many opportunities available.

## Project Resources

Accumulo makes use of the following external tools for development.

### GitHub

Apache Accumulo&reg; source code is maintained using [Git] version control and mirrored to [GitHub][github]. Source files can be browsed [here][browse] or at the [GitHub mirror][mirror]. 

The project code can be checked-out [here][mirror]. It builds with [Apache Maven][maven].

### JIRA

Accumulo [tracks issues][jiraloc] with [JIRA][jira]. Prospective code contributors can view [open issues labeled for "newbies"][newbies] to search for starter tickets. Note that every commit should reference a JIRA ticket of the form ACCUMULO-#. 

### Jenkins/TravisCI

Accumulo uses [Jenkins][jenkins] and [TravisCI](https://travis-ci.org/apache/accumulo) for automatic builds and continuous integration.

<img src="https://builds.apache.org/job/Accumulo-Master/lastBuild/buildStatus" style="height: 1.1em"> [Master][masterbuild]

<img src="https://builds.apache.org/job/Accumulo-1.8/lastBuild/buildStatus" style="height: 1.1em"> [1.8 Branch][18build]

<img src="https://builds.apache.org/job/Accumulo-1.7/lastBuild/buildStatus" style="height: 1.1em"> [1.7 Branch][17build]

## Create a Ticket for New Bugs or Feature

If you run into a bug or think there is something that would benefit the project, we encourage you to file an issue at the [Apache Accumulo JIRA][jiraloc] page. Regardless of whether you have the time to provide the fix or implementation yourself, this will be helpful to the project.

## Building Accumulo from Source

### Checking out from Git

There are several methods for obtaining the Accumulo source code. If you prefer to use SSH rather than HTTPS you can refer to the [GitHub help pages][github-help] for help in creating a GitHub account and setting up [SSH keys][ssh].

#### - from the Apache Hosted Repository

    git clone https://gitbox.apache.org/repos/asf/accumulo.git

#### - from the Github Mirror

    git clone https://github.com/apache/accumulo.git

#### - from your Github Fork

It is also possible to [fork][forking] a repository in GitHub so that you can freely experiment with changes without affecting the original project. You can then submit a [pull request](https://help.github.com/articles/about-pull-requests/) from your personal fork to the project repository when you wish to supply a contribution.

    git clone git@github.com:<account name>/accumulo.git

##### Retrieval of upstream changes 

Additionally, it is beneficial to add a git remote for the mirror to allow the retrieval of upstream changes.

    git remote add upstream http://github.com/apache/accumulo.git

## Running a Build

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

If you regularly switch between major development branches, you may receive errors about improperly licensed files from the [RAT plugin][rat]. This is caused by modules that exist in one branch and not the other leaving Maven build files that the RAT plugin no longer understands how to ignore.

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
    $> git checkout 2.0.0-SNAPSHOT
    Switched to branch '2.0.0-SNAPSHOT'
    $> git status
    # On branch 2.0.0-SNAPSHOT
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
    # On branch 2.0.0-SNAPSHOT
    nothing to commit (working directory clean)

## Providing a Contribution

The Accumulo source is hosted at [https://gitbox.apache.org/][repo] .

Like all Apache projects, a mirror of the git repository is also located on GitHub at [https://github.com/apache/accumulo][GitHub] which provides ease in [forking] and generating [pull requests (PRs)][pulls].

### Git

[Git][git] is an open source, distributed version control system
which has become very popular in large, complicated software projects due to
its efficient handling of multiple, simultaneously and independently developed
branches of source code.

### Workflow Background

The most likely contested subject matter regarding switching an active team
from one SCM tool to another is a shift in the development paradigm.

Some background, the common case, as is present with this team, is that
developers coming from a Subversion history are very light on merging being a
critical consideration on how to perform development. Because merging in
Subversion is typically of no consequence to the complete view of history, not
to mention that Subversion allows "merging" of specific revisions instead of
sub-trees. As such, a transition to Git typically requires a shift in mindset
in which a fix is not arbitrarily applied to trunk (whatever the main
development is called), but the fix should be applied to the earliest, non
end-of-life (EOL) version of the application.

For example, say there is a hypothetical application which has just released
version-3 of their software and have shifted their development to a version-4
WIP. Version-2 is still supported, while version-1 was just EOL'ed. Each
version still has a branch. A bug was just found which affects all released
versions of this application. In Subversion, considering the history in the
repository, it is of no consequence where the change is initially applied,
because a Subversion merge is capable of merging it to any other version.
History does not suffer because Subversion doesn't have the capacities to
accurately track the change across multiple branches. In Git, to maintain a
non-duplicative history, it is imperative that the developer choose the correct
branch to fix the bug in. In this case, since version-1 is EOL'ed, version-2,
version-3 and the WIP version-4 are candidates. The earliest version is
obviously version-2; so, the change should be applied in version-2, merged to
version-3 and then the version-4 WIP.

The importance of this example is making a best-attempt to preserve history
when using Git. While Git does have commands like cherry-pick which allow the
contents of a commit to be applied from one branch to another which are not
candidates to merge without conflict (which is typically the case when merging
a higher version into a lower version), this results in a duplication of that
commit in history when the two trees are eventually merged together. While Git
is smart enough to not attempt to re-apply the changes, history still contains
the blemish.

The purpose of this extravagant example is to outline, in the trivial case, how
the workflow decided upon for development is very important and has direct
impact on the efficacy of the advanced commands bundled with Git.

### Proposed Workflow

This is a summary of what has been agreed upon by vocal committers/PMC members
on [dev@accumulo.apache.org][dev-mail]. Enumeration of
every possible situation out of the scope of this document. This document
intends to lay the ground work to define the correct course of action regardless
of circumstances. Some concrete examples will be provided to ensure the
explanation is clear.

1. Active development is performed concurrently over no less than two versions
   of Apache Accumulo at any one point in time. As such, the workflow must
   provide guidance on how and where changes should be made which apply to
   multiple versions and how to ensure that such changes are contained in all
   applicable versions.

2. Releases are considered extremely onerous and time-consuming so no emphasis
   is placed on rapid iterations or development-cycles.

3. New features typically have lengthy development cycles in which more than
   one developer contributes to the creation of the new feature from planning,
   to implementation, to scale testing. Mechanisms/guidance should be provided
   for multiple developers to teach contribute to a remote-shared resource.

4. The repository should be the irrefutable, sole source of information
   regarding the development of Apache Accumulo, and, as such, should have
   best-efforts given in creating a clean, readable history without any single
   entity having to control all write access and changes (a proxy). In other
   words, the developers are the ones responsible for ensuring that previous
   releases are preserved to meet ASF policy, for not rewriting any public
   history of code not yet officially released (also ASF policy relevant) and
   for a best-effort to be given to avoid duplicative commits appearing in
    history created by the application of multiple revisions which have
    different identifying attributes but the same contents (git-rebase and
    git-cherry-pick).

## The Implementation

The following steps, originally derived from Apache kafka's 
[simple contributor workflow][kafka], will demonstrate the gitflow implementation.

### Contributors

To be specific, let's consider a contributor wanting to work on a fix for the
Jira issue ACCUMULO-12345 that affects the 1.8 release.

1. Ensure you configured Git with your information

    `git config --global user.name 'My Name' && git config --global user.email
    'myname@mydomain.com'`

2. Clone the Accumulo repository:

    `git clone https://gitbox.apache.org/repos/asf/accumulo.git accumulo`

3. or update your local copy:

    `git fetch && git fetch --tags`

4. For the given issue you intend to work on, choose the 'lowest' fixVersion
   and create a branch for yourself to work in. This example is against the next release of 1.8

    `git checkout -b ACCUMULO-12345-my-work origin/1.8`

5. Make commits as you see fit as you fix the issue, referencing the issue name
   in the commit message:

    `git commit -av`

    Please include the ticket number at the beginning of the log message, and
    in the first line, as it's easier to parse quickly. For example:

    `ACCUMULO-2428 throw exception when rename fails after compaction`

    Consider following the git log message format described in
    [Zach Holman's talk](https://zachholman.com/talk/more-git-and-github-secrets/)
    (specifically slides 78-98, beginning at 15:20 into the video). Essentially,
    leave a short descriptive message in the first line, skip a line, and write
    more detailed stuff there, if you need to. For example:

```
    ACCUMULO-2194 Add delay for randomwalk Security teardown

    If two Security randomwalk tests run back-to-back, the second test may see that the
    table user still exists even though it was removed when the first test was torn down.
    This can happen if the user drop does not propagate through Zookeeper quickly enough.
    This commit adds a delay to the end of the Security test to give ZK some time.
```

6. Assuming others are developing against the version you also are, as you
   work, or before you create your patch, rebase your branch against the remote
   to lift your changes to the top of your branch. The branch specified here should be the same one you used in step 4.

    `git pull --rebase origin 1.8`

7. At this point, you can create a patch file from the upstream branch to
   attach to the ACCUMULO-12345 Jira issue. The branch specified here should be the same one you used in step 4.

    `git format-patch --stdout origin/1.8 > ACCUMULO-12345.patch`

An alternative to creating a patch is submitting a request to pull your changes
from some repository, e.g. GitHub. Please include the repository and branch
name merge in the notice to the Jira issue, e.g.

    repo=git://github.com/<username>/accumulo.git branch=ACCUMULO-12345

A second alternative is to use Github's "Pull Requests" feature against the
[Apache Accumulo account](https://github.com/apache/accumulo). Notifications of
new pull-requests from Github should automatically be sent to
[dev@accumulo.apache.org][dev-mail].

Ignoring specifics, contributors should be sure to make their changes against
the earlier version in which the fix is intended, `git-rebase`'ing their
changes against the upstream branch so as to keep their changes co-located and
free of unnecessary merges.

### Developers

#### Primary Development

Primary development should take place in `master` which is to contain the most
recent, un-released version of Apache Accumulo. Branches exist for minor releases
for each previously released major version. 

Using long-lived branches that track a major release line simplifies management and
release practices. Developers are encouraged to make branches for their own purposes,
for large features, release candidates or whatever else is deemed useful.

#### Reviewing contributor changes

It is always the responsibility of committers to determine that a patch is
intended and able to be contributed.  From the
[new committer's guide](https://www.apache.org/dev/new-committers-guide#cla):
"Please take care to ensure that patches are original works which have been
clearly contributed to the ASF in public. In the case of any doubt (or when a
contribution with a more complex history is presented) please consult your
project PMC before committing it."

Extra diligence may be necessary when code is contributed via a pull request.
Committers should verify that the contributor intended to submit the code as a 
Contribution under the [Apache License](https://www.apache.org/licenses/LICENSE-2.0.txt).
When pulling the code, committers should also verify that the commits pulled match the 
list of commits sent to the Accumulo dev list in the pull request.

#### Submit Contribution via Patch

Developers should use the following steps to apply patches from
contributors:

1. Checkout the branch for the major version which the patch is intended:

    `git checkout 1.8`

2. Verify the changes introduced by the patch:

    `git apply --stat ACCUMULO-12345.patch`

3. Verify that the patch applies cleanly:

    `git apply --check ACCUMULO-12345.patch`

4. If all is well, apply the patch:

    `git am --signoff < ACCUMULO-12345.patch`

5. When finished, push the changes:

    `git push origin 1.8`

6. Merge where appropriate:

    `git checkout master && git merge 1.8`

#### Submit Contrribution via Pull-Request

If the contributor submits a repository and branch to pull
from, the steps are even easier:

1. Add their repository as a remote to your repository

    `git remote add some_name ${repository}`

2. Fetch the refs from the given repository

    `git fetch ${repository}`

3. Merge in the given branch to your local branch

    `git merge some_name/${branch}`

4. Delete the remote:

    `git remote remove some_name`

If the branch doesn't fast-forward merge, you likely want to inform the
contributor to update their branch to avoid the conflict resolution and merge
commit. See the [Git
manual](https://git-scm.com/book/en/Git-Branching-Basic-Branching-and-Merging)
for more information on merging. When merging a pull-request, it's best to **not**
include a signoff on the commit(s) as it changes the final commit ID in the
Accumulo repository. This also has the negative effect of not automatically closing
the Pull-Request when the changes are made public.

#### Feature Branches

Ease in creating and using feature branches is a desirable merit which Git
provides with little work. Feature branches are a great way in which developers
to work on multiple, long-running features concurrently, without worry of
mixing code ready for public-review and code needing more internal work.
Additionally, this creates an easily consumable series of commits in which
other developers can track changes, and see how the feature itself evolved.

To prevent developers' feature branches from colliding with one another, it was
suggested to impose a "hierarchy" in which shared feature branches are prefixed
with `<apache_id>/ACCUMULO-<issue#>[-description]`.

1. Create a branch off of `master`.

    `git checkout <apache_id>/ACCUMULO-<issue#> master`

2. Create the feature, committing early and often to appropriately outline the
"story" behind the feature and it's implementation.

3. As long as you have not collaborating with others, `git-rebase` your feature
branch against upstream changes in `master`

    `git fetch && git rebase origin/master`

4. If you are actively collaborating with others, you should be nice and not
change their history. Use `git-merge` instead.

    `git fetch && git merge origin/master`

5. Continue steps 2 through 4 until the feature is complete.

6. Depending on the nature, duration and history of the changes in your feature
branch, you can choose to:

    * **'Simple' Merge**: 

        `git checkout master && git merge <apache_id>/ACCUMULO-<issue#>`

    * **Rebase and merge** -- keeps all feature-branch commits
      co-located: 

        `git fetch && git rebase origin/master && git checkout master && git merge <apache_id>/ACCUMULO-<issue#>`

    * **Merge with squash** -- feature branch history is a mess, just make one commit
      with the lump-sum of your feature branch changes: 

        `git checkout master && git merge --squash <apache_id>/ACCUMULO-<issue#>`

#### Changes which affect multiple versions (a.k.a. merging)

Merging can be a very confusing topic for users switching to Git, but it can be
summarized fairly easily.

0. **Precondition**: choose the right branch to start! (lowest, applicable version
   for the change)

1. Get your changes fixed for that earliest version.

2. Switch to the next highest version which future minor versions will be
   released (non-EOL major release series).

3. `git-merge` the branch from #1 into the current.

4. In the face of conflicts, use options from `git-merge` to help you.

    * `git checkout new-version && git merge --stat old-version`
    * `git checkout new-version && git merge --no-commit old-version`

5. Treat your current branch as the branch from #2, and repeat from #2.

When merging changes across major releases, there is always the possibility of
changes which are applicable/necessary in one release, but not in any future
releases, changes which are different in implementation due to API changes, or
any number of other cases. Whatever the actual case is, the developer who made
the first set of changes (you) is the one responsible for performing the merge
through the rest of the active versions. Even when the merge may results in a
zero-length change in content, this is incredibly important to record, as you
are the one who knows that this zero-length change in content is correct!

## Code review process

Accumulo primarily uses GitHub (via pull requests) for code reviews, but has access to an instance of [Review Board](https://reviews.apache.org/) as well if that is preferred.

Accumulo operates under the [Commit-Then-Review](https://www.apache.org/foundation/glossary#CommitThenReview) (CtR) policy, so a code review does not need to occur prior to commit. However, a commiter has the option to hold a code review before a commit happens if, in their opinion, it would benefit from additional attention. Full details of the code review process for Accumulo is documented [here](./rb)

### Review Board

Use of [Review Board][rb] has slowly diminished and been gradually replaced by GitHub reviews over the past year or so.

## Additional Contributor Information

### Coding Practices

{: .table}
| **License Header**              | Always add the current ASF license header as described in [ASF Source Header][srcheaders].            |
| **Trailing Whitespaces**        | Remove all trailing whitespaces. Eclipse users can use Source&rarr;Cleanup option to accomplish this. |
| **Indentation**                 | Use 2 space indents and never use tabs!                                                               |
| **Line Wrapping**               | Use 160-column line width for Java code and Javadoc.                                                  |
| **Control Structure New Lines** | Use a new line with single statement if/else blocks.                                                  |
| **Author Tags**                 | Do not use Author Tags. The code is developed and owned by the community.

### Merging Practices

Changes should be merged from earlier branches of Accumulo to later branches. Ask the [dev list][dev-mail] for instructions.

### Project Examples

A collection of Accumulo example code can be found at the [Accumulo Examples repository][examples].

### Website Contributions

The source for this website is a collection of markdown documents that are converted to HTML using
[Jekyll]. It can be found in the [accumulo-website repo][website-repo]. If you would like to make changes to this website, clone the website repo and edit the markdown:

```
    git clone https://github.com/apache/accumulo-website.git
```

After you have made your changes, follow the instructions in the [README.md][website-readme] to run the website locally and make a pull request on [GitHub][website-repo]. If you have problems installing Jekyll or running the website locally, it's OK to proceed with the pull request. A committer will review your changes before committing them and updating the website.

### Public API

Refer to the README in the release you are using to see what packages are in the public API.

Changes to non-private members of those classes are subject to additional scrutiny to minimize compatibility problems across Accumulo versions.   

### Installing Apache Thrift

If you activate the ‘thrift’ Maven profile, the build of some modules will attempt to run the Apache Thrift command line to regenerate stubs. If you activate this profile and don’t have Apache Thrift installed and in your path, you will see a warning and your build will fail. For Accumulo 1.5.0 and greater, install Thrift 0.9 and make sure that the ‘thrift’ command is in your path. Watch out for THRIFT-1367; you may need to configure Thrift with –without-ruby. Most developers do not need to install or modify the Thrift definitions as a part of developing against Apache Accumulo.

## Committer Documentation

The links below are provided primarily for the project committers but may be of interest to contributors as well.

- [Release Management][release]
- [Making a Release][making]
- [Verifying a Release][verifying]

## Project Governance

For details about governance policies for the Accumulo project view the following links.

- [Bylaws][36]
- [Consensus Building][37]
- [Lazy Consensus][38]
- [Voting][39]

## IDE Configuration Tips

### Eclipse

* Download Eclipse [formatting and style guides for Accumulo][styles].
* Import Formatter: `Preferences > Java > Code Style >  Formatter` and import the `Eclipse-Accumulo-Codestyle.xml` downloaded in the previous step. 
* Import Template: `Preferences > Java > Code Style > Code Templates` and import the `Eclipse-Accumulo-Template.xml`. Make sure to check the "Automatically add comments" box. This template adds the ASF header and so on for new code.

### IntelliJ

 * Formatter [plugin][intellij-formatter] that uses eclipse code style xml.

## Contact us!

The developer mailing list [(dev@accumulo.apache.org)][dev-mail] is monitored pretty closely, and we tend to respond quickly.  If you have a question, don't hesitate to send us an e-mail! Unfortunately, though, e-mails can get lost in the shuffle, so if you do send an e-mail and don't get a response within a day or two, just ping the mailing list again.



[1]: #how-to-contribute-to-apache-accumulo
[2]: #project-resources
[3]: #github
[4]: #jira
[5]: #jenkinstravisci
[6]: #create-a-ticket-for-new-bugs-or-feature
[7]: #building-accumulo-from-source
[8]: #checking-out-from-git
[9]: #running-a-build
[10]: #providing-a-contribution
[11]: #proposed-workflow
[12]: #the-implementation
[13]: #contributors
[14]: #developers
[15]: #primary-development
[16]: #reviewing-contributor-changes
[17]: #submit-contribution-via-changes
[18]: #submit-contribution-via-pull-request
[19]: #feature-branches
[20]: #changes-which-affect-multiple-versions-aka-merging
[21]: #code-review-process
[22]: #additional-contributor-information
[23]: #merging-practices
[24]: #public-api
[25]: #coding-practices
[26]: #project-examples
[27]: #website-contributions
[28]: {{ site.baseurl }}/contributor/contrib-projects
[29]: #installing-apache-thrift
[32]: #committer-documentation
[33]: #project-governance
[34]: #ide-configuration-tips
[35]: #contact-us
[36]: {{ site.baseurl }}/contributor/bylaws
[37]: {{ site.baseurl }}/contributor/consensusBuilding
[38]: {{ site.baseurl }}/contributor/lazyConsensus
[39]: {{ site.baseurl }}/contributor/voting
[manual]: {{ site.baseurl }}/{{ site.latest_minor_release }}/accumulo_user_manual.html
[quickstart1x]: {{ site.baseurl }}/quickstart-1.x/
[quickstart2x]: {{ site.baseurl }}/quickstart-2.x/
[Uno]: https://github.com/astralway/uno
[get-involved]: {{ site.baseurl }}/get_involved
[git]: https://git-scm.com/
[github]: https://github.com/apache/accumulo
[pulls]: https://github.com/apache/accumulo/pulls
[browse]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=summary
[mirror]: https://github.com/apache/accumulo
[maven]: https://maven.apache.org/
[jekyll]: https://jekyllrb.com
[jiraloc]: https://issues.apache.org/jira/browse/ACCUMULO
[jira]: https://www.atlassian.com/software/jira
[newbies]: https://s.apache.org/newbie_accumulo_tickets
[Jenkins]: https://builds.apache.org/view/A/view/Accumulo
[masterbuild]: https://builds.apache.org/job/Accumulo-Master
[18build]: https://builds.apache.org/job/Accumulo-1.8
[17build]: https://builds.apache.org/job/Accumulo-1.7
[github-help]: https://help.github.com/
[ssh]: https://help.github.com/articles/connecting-to-github-with-ssh/
[forking]: https://help.github.com/articles/fork-a-repo/
[pom]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=blob_plain;f=pom.xml;hb=HEAD
[lifecycle]: https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle
[rb]: {{site.baseurl }}/contributor/rb
[rat]: https://creadur.apache.org/rat/apache-rat-plugin
[repo]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=summary
[pulls]: https://help.github.com/articles/using-pull-requests/
[dev-mail]: mailto:dev@accumulo.apache.org
[kafka]: https://cwiki.apache.org/confluence/display/KAFKA/Patch+submission+and+review#Patchsubmissionandreview-Simplecontributorworkflow
[examples]: https://github.com/apache/accumulo-examples
[website-repo]: https://github.com/apache/accumulo-website
[website-readme]: https://github.com/apache/accumulo-website/blob/master/README.md
[styles]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=tree;f=contrib;hb=HEAD
[intellij-formatter]: https://code.google.com/p/eclipse-code-formatter-intellij-plugin
[release]: {{site.baseurl }}/contributor/release-management
[making]: {{site.baseurl }}/contributor/making-release
[verifying]: https://accumulo.apache.org/contributor/verifying-release

