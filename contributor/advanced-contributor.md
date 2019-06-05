---
title: Advanced Contributor
---

## Apply patch from contributor

Developers should use the following steps to apply patches from
contributors:

1. Checkout the branch for the major version which the patch is intended:

    `git checkout 1.9`

2. Verify the changes introduced by the patch:

    `git apply --stat ACCUMULO-12345.patch`

3. Verify that the patch applies cleanly:

    `git apply --check ACCUMULO-12345.patch`

4. If all is well, apply the patch:

    `git am --signoff < ACCUMULO-12345.patch`

5. When finished, push the changes:

    `git push origin 1.9`

6. Merge where appropriate:

    `git checkout master && git merge 1.9`

## Merging change to multiple versions

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

Accumulo primarily uses GitHub (via pull requests) for code reviews.

Accumulo operates under the [Commit-Then-Review](https://www.apache.org/foundation/glossary#CommitThenReview) (CtR) policy, so a code review does not need to occur prior to commit. However, a committer has the option to hold a code review before a commit happens if, in their opinion, it would benefit from additional attention. Full details of the code review process for Accumulo is documented [here](./rb)

## Coding Practices

{: .table}
| **License Header**              | Always add the current ASF license header as described in [ASF Source Header][srcheaders].            |
| **Trailing Whitespaces**        | Remove all trailing whitespaces. Eclipse users can use Source&rarr;Cleanup option to accomplish this. |
| **Indentation**                 | Use 2 space indents and never use tabs!                                                               |
| **Line Wrapping**               | Use 100-column line width for Java code and Javadoc.                                                  |
| **Control Structure New Lines** | Use a new line with single statement if/else blocks.                                                  |
| **Author Tags**                 | Do not use Author Tags. The code is developed and owned by the community.

## Merging Practices

Changes should be merged from earlier branches of Accumulo to later branches. Ask the [dev list][dev-mail] for instructions.

[dev-mail]: mailto:dev@accumulo.apache.org
