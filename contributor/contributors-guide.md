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
[bylaws]: {{ site.baseurl }}/contributor/bylaws
[consensus]: {{ site.baseurl }}/contributor/consensusBuilding
[lazy]: {{ site.baseurl }}/contributor/lazyConsensus
[voting]: {{ site.baseurl }}/contributor/voting
