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

Eventually JIRA will be transitioned to a read-only state for reference.  For
finding issues to work, there may still be 
[open issues labeled for newbies][newbie-issues] in JIRA.

## GitHub Labels

Labels, such as `bug`, `enhancement`, and `duplicate`, are used to
descriptively organize issues and pull requests. Issues labeled with `blocker`
indicate that the developers have determined that the issue must be fixed prior
to a release (to be used in conjunction with a version-specific project board;
see the next section for information on project boards).

Currently only Accumulo committers can set labels.  If you think a label should
be set, comment on the issue and someone will help.

## GitHub Project Boards (Projects)

Project boards (also "projects") are used to track the status of issues and
pull requests for a specific milestone. Projects with names such as `2.1.0`,
and `1.9.2` are used for tracking issues associated with a particular release
and release planning. These are set up as basic Kanban boards with automation,
with `To do`, `In progress`, and `Done` statuses. These projects are marked as
"closed" when the version indicated is released. Other projects may exist for
miscellaneous puposes, such as tracking multiple issues related to a larger
effort. These projects will be named appropriate to indicate their purpose.

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

## Project Governance

For details about governance policies for the Accumulo project view the following links.

- [Bylaws][bylaws]
- [Consensus Building][consensus]
- [Lazy Consensus][lazy]
- [Voting][voting]

[How to Contribute]: /how-to-contribute/
[manual]: {{ site.docs_baseurl }}
[get-involved]: {{ site.baseurl }}/get_involved
[mirror]: https://github.com/apache/accumulo
[repo]: https://gitbox.apache.org/repos/asf?p=accumulo.git;a=summary
[website-repo]: https://github.com/apache/accumulo-website
[website-readme]: https://github.com/apache/accumulo-website/blob/master/README.md
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
