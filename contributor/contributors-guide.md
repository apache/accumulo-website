---
title: Contributor Guide
permalink: /contributors-guide/
---

**Please read the [How to Contribute] page first before reading this guide.** This page contains additional project
documentation.

Accumulo previously used [JIRA], but now uses GitHub issues.
All new issues should be opened using GitHub. If working an existing JIRA
issue, please do the following :

 * Open a new GitHub issue or pull request.
 * Link the GitHub issue to the JIRA issue.
 * Link the JIRA issue to the GitHub issue.
 * Close the JIRA issue as a duplicate.

Eventually, JIRA will be transitioned to a read-only state for reference.  For
finding issues to work, there may still be 
[open issues labeled for newbies][newbie-issues] in JIRA.

## GitHub Project Boards (Projects)

Project boards (also "projects") are used to track the status of issues and
pull requests for a specific milestone. Projects with names such as `2.1.0`,
and `1.9.2` are used for tracking issues associated with a particular release
and release planning. These are set up as basic Kanban boards with automation,
with `To do`, `In progress`, and `Done` statuses. These projects are marked as
"closed" when the version indicated is released. Other projects may exist for
miscellaneous puposes, such as tracking multiple issues related to a larger
effort. These projects will be named appropriately to indicate their purpose.

## For Contributors

The docs below provide additional information for contributors.

- [Building Accumulo][building]
- [Advanced Contributor][advanced]

## For Committers

The docs below are for committers but may be of interest to contributors as well.

- [Release Management][release]
- [Making a Release][making]
- [Verifying a Release][verifying]
- [Testing a Release][testing]

## Code Editors

Feel free to use any editor when contributing Accumulo. If you are looking for a recommendation, many Accumulo
developers use [IntelliJ] or [Eclipse]. Below are some basic instructions to help you get started.

### IntelliJ

1. Download and install [IntelliJ]
1. Clone the Accumulo repository that you want to work on.
   ```shell
   git clone https://github.com/apache/accumulo.git
   ```
1. [Import][intellij-import] the repository as a Maven project into IntelliJ
1. (Optional) Download and import `Eclipse-Accumulo-Codestyle.xml` from Accumulo's [contrib][accumulo-contrib] directory
  * Import via `File` > `Settings` > `Code Style` and clicking on cog wheel

### Eclipse

1. Download and install [Eclipse].
1. Clone the Accumulo repository that you want to work on.
   ```shell
   git clone https://github.com/apache/accumulo.git
   ```
1. [Import][eclipse-import] the repository as a Maven project into Eclipse
1. (Optional) Download and import Eclipse formatting and style guides from Accumulo's [contrib][accumulo-contrib] directory
  * Import Formatter: `Preferences` > `Java` > `Code Style` > `Formatter` and import the `Eclipse-Accumulo-Codestyle.xml` downloaded in the previous step.
  * Import Template: `Preferences` > `Java` > `Code Style` > `Code Templates` and import the `Eclipse-Accumulo-Template.xml`. Make sure to check the "Automatically add comments" box. This template adds the ASF header and so on for new code.

## Project Governance

For details about governance policies for the Accumulo project view the following links.

- [Bylaws][bylaws]
- [Consensus Building][consensus]
- [Lazy Consensus][lazy]
- [Voting][voting]

[How to Contribute]: /how-to-contribute/
[newbie-issues]: https://s.apache.org/newbie_accumulo_tickets
[JIRA]: https://issues.apache.org/jira/browse/ACCUMULO
[building]: {{ site.baseurl }}/contributor/building
[advanced]: {{ site.baseurl }}/contributor/advanced-contributor
[release]: {{ site.baseurl }}/contributor/release-management
[making]: {{ site.baseurl }}/contributor/making-release
[verifying]: /contributor/verifying-release
[testing]: /contributor/testing-release
[Eclipse]: https://www.eclipse.org/
[eclipse-import]: https://stackoverflow.com/questions/2061094/importing-maven-project-into-eclipse
[Intellij]: https://www.jetbrains.com/idea/
[intellij-import]: https://www.jetbrains.com/help/idea/maven.html#maven_import_project_start
[accumulo-contrib]: https://github.com/apache/accumulo/tree/master/contrib
[bylaws]: {{ site.baseurl }}/contributor/bylaws
[consensus]: {{ site.baseurl }}/contributor/consensusBuilding
[lazy]: {{ site.baseurl }}/contributor/lazyConsensus
[voting]: {{ site.baseurl }}/contributor/voting
