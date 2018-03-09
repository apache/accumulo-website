---
title: "Migrating to GitHub Issues"
---

Apache Accumulo is migrating from [JIRA] to [GitHub issues][ghi]. The migration is starting with an initial plan, but it may change as the community uses it.  For a description of the initial operating plan see the [issues section of How to Contribute](/how-to-contribute/#issues) and the [triaging issues section of Making a Release](/contributor/making-release#triage-issues).

## Motivation

Doing routine activities in less time is one motivation for the migration.  Below are some examples.

 * For GitHub a pull request is an issue. Therefore, creating an issue before a pull request is optional. Before the migration, an issue needed to be created in JIRA before creating a pull request. This was cumbersome for small changes.
 * When browsing commits in GitHub, issue numbers can be clicked.
 * Discussions on pull request can easily reference issues with simple markdown syntax.
 * Commits can close issues if the commit message contains "fixes #xyz"

## Migration

There is no plan to migrate all existing issues in JIRA. The plan is to only migrate issues that someone is interested in or are actively being worked. Migration is done by linking the JIRA and GitHub issues to each other and then closing the JIRA issue. No new issues should be opened in JIRA.  JIRA will eventually be transitioned to a read only state.

[JIRA]: https://issues.apache.org/jira/browse/ACCUMULO
[ghi]: https://github.com/apache/accumulo/issues
