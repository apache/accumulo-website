---
title: Release Management
redirect_from: /release-management
---

Releases, although not a day to day task, have their own unique steps which are to be followed. Releases can be categorized in to minor and major releases

### A minor release

A minor release is some set of changes `z'` on top of a version `x.y.z`.
Typically, `z'` is simply `z + 1`, e.g. given a release named '1.6.0', and the
next minor release is '1.6.1'. These changes for `z'` should not break any
client code which works against `z` and should absolutely not change the public
API.

By convention, the branch containing the changes `z'` should be named
`x.y` (where the changes for `z'` are commits since `x.y.z`. The steps to take are as follows:

1. [Make a release candidate][making]
2. Create a branch for the release candidate from the `x.y` branch,
   named something like `x.y.z'-RCN`.
3. Test and Vote
4. Create a GPG-signed tag with the correct final name: `x.y.z'`
5. Push a delete of the remote branch `x.y.z'-RCN`

This process is not firm and should not be viewed as requirements for making a release.
The release manager is encouraged to make use branches/tags in whichever way is best.

### A major release

A major release is a release in which multiple new features are introduced
and/or the public API are modified. The major release `y'`, even when the
client API is not modified, will typically contain many new features and
functionality above the last release series `y`. A major release also resets
the `z` value back to `0`.

The steps to create a new major release are very similar to a minor release:

1. [Make a release candidate][making]
2. Create a tag of the release candidate from the `x.y` branch,
   named something like `x.y.0-RCN`.
3. Test and Vote
4. Create a GPG-signed tag with the correct final name: `x.y.0`
5. Push a delete of the remote branch `x.y.0-RCN`


# The infrastructure

This section deals with the changes that must be requested through INFRA. As
with any substantial INFRA request, the VOTE and result from the mailing should
be referenced so INFRA knows that the request has been acknowledged. Likely, a
PMC member should be the one to submit the request.

## Repositories

I believe that we will need multiple repositories to best align ourselves with
how we currently track "Accumulo" projects. The repositories follow:

1. The main source tree. This will track the standard trunk, branches, tags
   structure from Subversion for Apache Accumulo.

2. One repository for every project in
   [contrib](https://svn.apache.org/repos/asf/accumulo/contrib): Accumulo-BSP,
   Instamo Archetype, and the Wikisearch project. Each of these
   are considered disjoint from one another, and the main source tree, so they
   each deserve their own repository.

Given the list of repositories that currently exist on the [ASF
site](https://git-wip-us.apache.org/repos/asf) and a brief search over INFRA
tickets, multiple repositories for a single Apache project is not an issue.
Having this list when making the initial ticket will likely reduce the amount
of work necessary in opening multiple INFRA tickets.

## Mirroring

It should be noted in the INFRA request that each repository will also need to
be configured to properly mirror to the [ASF Github](https://github.com/apache)
account to provide the same functionality with current have via the git+svn
mirror. Same change needs to be applied for the [Apache hosted](https://git.apache.org) 
mirror'ing.

## Mailing lists

It should be noted in the INFRA request that commit messages should be sent to
[commits@accumulo.apache.org](mailto:commits@accumulo.apache.org). The subject
can be decided on using the [provided
variables](https://git-wip-us.apache.org/docs/switching-to-git#contents).

# Examples

For the sake of clarity, some examples of common situations are included below.

## Releasing 1.6.0

1. Branch from `master` to `1.6`

    `git checkout master && git branch 1.6`

2. Tag `1.6.0-RC1` from the just created `1.6` branch

    `git tag 1.6.0-RC1 1.6`

3. Test, vote, etc. and tag from 1.6.0-RC1

    `git -s tag 1.6.0 1.6.0-RC1`

4. Delete the RC tag, if desired.

    `git tag -d 1.6.0-RC1 && git push --delete origin 1.6.0-RC1`

5. Ensure `master` contains all features and fixes from `1.6.0`

    `git checkout master && git merge 1.6`

6. Update the project version in `master` to 1.7.0-SNAPSHOT


[1]: https://cwiki.apache.org/confluence/display/KAFKA/Patch+submission+and+review#Patchsubmissionandreview-Simplecontributorworkflow
[making]: {{ site.baseurl }}/contributor/making-release
