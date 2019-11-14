---
title: How To Contribute
permalink: /how-to-contribute/
redirect_from: /contributor/
---

Contributions are welcome to all Apache Accumulo repositories. While most contributions are code,
there are other ways to contribute to Accumulo:

* communicate on one of the [mailing lists](/contact-us/#mailing-lists)
* review [pull requests](https://github.com/apache/accumulo/pulls)
* verify and test new [releases](/release/)
* update the [Accumulo website and documentation](https://github.com/apache/accumulo-website)
* report bugs or triage issues

First time developers should start with an issue labeled [good first issue][good-first-issue].

Any questions/ideas don't hesitate to [contact us][contact].

## Accumulo Repositories

| Repository         | Links                          | Description
| -------------------| ------------------------------ | -----------
| [Accumulo][a]      | [Contribute][ac] [Issues][ai]  | Core Project
| [Website][w]       | [Contribute][wc] [Issues][wi]  | Source for this website
| [Examples][e]      | [Contribute][ec] [Issues][ei]  | Example code
| [Testing][t]       | [Contribute][tc] [Issues][ti]  | Test suites such as continuous ingest and random walk
| [Docker][d]        | [Contribute][dc] [Issues][di]  | Source for Accumulo Docker image
| [Wikisearch][s]    | [Contribute][sc] [Issues][si]  | Example application that indexes and queries Wikipedia data
| [Proxy][p]         | [Issues][pi]                   | Apache Thrift service that exposes Accumulo to other languages
| [Maven plugin][m]  | [Issues][mi]                   | Maven plugin that runs Accumulo

## Example Contribution workflow

1. Create a [GitHub account][github-join] for issues and pull requests.
1. Find an [issue][good-first-issue] to work on or optionally create one that describes the work that you want to do.
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
1. Create a [Pull Request] on GitHub to the appropriate repository. A [draft pull request] can be used if the work is not complete.
1. At least one committer (and others in the community) will review your pull request and add any comments to your code.
1. Push any changes from the review to the branch as new commits so the reviewer only needs to review new changes. Please avoid squashing commits after the review starts. Squashing makes it hard for the reviewer to follow the changes.
1. Repeat this process until a reviewer approves the pull request.
1. When the review process is finished, all commits on the pull request may be squashed by a committer. Please avoid squashing as it makes it difficult for the committer to know if they are merging what was reviewed.

## Coding Guidelines

* Accumulo follows [semver] for its [public API](/api/).
* Every file requires the ASF license header as described in [ASF Source Header][srcheaders].
* Do not use Author Tags. The code is developed and owned by the community.

## Helpful Links

* **Build resources** - [TravisCI] & [Jenkins][jenkins]
* **Releases** - [Making a release][making], [Verifying a release][verifying]

For more information, see the [contributor guide](/contributors-guide/).

[good-first-issue]: https://github.com/apache/accumulo/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
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
[p]: https://github.com/apache/accumulo-proxy
[pi]: https://github.com/apache/accumulo-proxy/issues
[m]: https://github.com/apache/accumulo-maven-plugin
[mi]: https://github.com/apache/accumulo-maven-plugin/issues
[github-join]: https://github.com/join
[GitHub]: https://github.com/apache/accumulo/pulls
[Jenkins]: https://builds.apache.org/view/A/view/Accumulo
[TravisCI]: https://travis-ci.org/apache/accumulo
[making]: {{ "/contributor/making-release" | relative_url }}
[verifying]: {{ "/contributor/verifying-release" | relative_url }}
[Fork]: https://help.github.com/articles/fork-a-repo/
[Pull Request]: https://help.github.com/articles/about-pull-requests/
[draft pull request]: https://github.blog/2019-02-14-introducing-draft-pull-requests/
[Push]: https://help.github.com/articles/pushing-to-a-remote/
[clone]: https://help.github.com/articles/cloning-a-repository/
[srcheaders]: https://www.apache.org/legal/src-headers
[semver]: http://semver.org/spec/v2.0.0.html
[messages]: https://chris.beams.io/posts/git-commit/
[squash-tutorial]: http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html
[squash-stack]: https://stackoverflow.com/questions/5189560/squash-my-last-x-commits-together-using-git
