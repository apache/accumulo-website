---
title: Bylaws
redirect_from:
  - /bylaws
  - /governance/bylaws
---

This is version 4 of our project's bylaws and is subject to change.

# Introduction

Accumulo is a project of the [Apache Software Foundation (ASF)][foundation].
More details about the Foundation can be found on its pages.

Accumulo is a typical ASF project, operating under a set of principles known
collectively as [The Apache Way][thisistheway]. If you are new to ASF
development, please refer to the [Incubator project][incubator] for more
information on how ASF projects operate.

Terms used at the ASF are defined in the [ASF glossary][glossary].

While this project generally follows standard procedures used by most projects
across the ASF, the purpose of this document is to define bylaws that apply
specifically to the Accumulo project. These bylaws establish ground rules for
handling situations where either there is no standard procedure within the ASF,
or where we've chosen to diverge from those procedures. If a situation is not
covered by these bylaws, then it is assumed that we will follow standard
procedures established by the Foundation. If standard procedures do not exist,
then a decision should be made following a discussion on an appropriate mailing
list for the project.


# Roles and Responsibilities

The roles in this project, and their associated responsibilities, are the
standard roles defined within the Foundation's [own documents][how-it-works].

This project establishes the following additional procedures for specific
roles below.

## Committers

The Committer role is defined by [the Foundation][how-it-works]. Additional
information can be found on the [Committers page][committer-faq].

Upon acceptance of an invitation to become a committer, it is the accepting
committer's responsibility to update their status on the Accumulo web page
accordingly, and to make updates as needed.

All committers should use their privileges carefully, and ask for help if they
are uncertain about the risks of any action.

In order to maintain a low barrier to entry, and to encourage project growth
and diversity of perspectives, it is the custom of the Accumulo project to also
invite each committer to become a member of its Project Management Committee
(PMC). However, this is not a requirement and the current PMC may elect to only
invite a contributor to become a committer without inviting them to become a
PMC member, depending on the circumstances. If invited to both, invitees may
also decline the invitation to the PMC role and only accept the committer role.

## Project Management Committee (PMC) Member

The PMC Member role is defined by [the Foundation][how-it-works]. Additional
information can be found in the [PMC Guide][pmc-guide].

Some specific responsibilities of the PMC for Accumulo include:

* Voting on releases to determine what is distributed as a product of the Accumulo project
* Maintaining the project's shared resources, including the code repository, mailing lists, and websites
* Protecting ASF trademarks, including the Accumulo name and logo, and ensuring their proper use by others
* Subscribing to the private mailing list and engaging in decisions and discussions
* Speaking on behalf of the project
* Nominating new PMC members and committers
* Maintaining these bylaws and other guidelines of the project

In particular, PMC members must understand both our project's criteria and ASF
criteria for voting on a [release][release-management].

Upon acceptance of an invitation to become a PMC member, it is the accepting
member's responsibility to update their status on the Accumulo web page
accordingly, and to make updates as needed.

Because the PMC is a role within the Foundation, changes to PMC membership
follow criteria established by the board. In general, this means that the board
chooses who gets added or removed from the PMC, but they may delegate that
authority to existing PMC members or the PMC chair. However, it is this
project's practice to collectively make decisions about PMC additions among the
existing PMC members on the project's private mailing list. Accordingly, the
existing PMC members will conduct a vote before inviting new PMC members, so
long as that vote can be done without violating the board's current procedures.
Depending on the current board procedures, this vote may be merely advisory.
Additionally, no vote will be conducted without first being preceded by a
discussion period of at least 72 hours.

PMC members may voluntarily resign from the PMC at any time by their own
request, and following the appropriate procedures for PMC membership changes
established by the board. These former members will be recognized as "Emeritus"
PMC members on the Accumulo web site, in honor of their past contributions.
Having resigned from the PMC role, these former members will no longer have any
privileges of PMC membership, such as binding votes for releases or other
project decisions. However, they will retain any committer privileges, and may
retain access to the PMC's private mailing list. Emeritus PMC members, having
voluntarily resigned, may request to rejoin the PMC and restore their
privileges, without a vote of the existing PMC members, provided that all other
procedures for PMC membership changes established by the board are followed.

## PMC Chair

The chair of the PMC (PMC Chair) is appointed by the ASF board. The chair is an
office holder of the Apache Software Foundation (Vice President, Apache
Accumulo) and has primary responsibility to the board for the management of the
projects within the scope of the Accumulo PMC. The chair reports to the board
quarterly on developments within the Accumulo project.

The current PMC members may at any time vote to recommend a new chair (such as
when the current chair declares their desire to resign from the role), but the
decision must be ratified by the Apache board before the recommended person can
assume the role.

In the event that the PMC Chair is delegated any special authority by the board
to make decisions for the project, that they will first make a good faith
effort to achieve consensus from the existing PMC members, and will act without
such consensus only if necessary. For example, if the board delegates the
authority to make additions to the PMC membership, the chair should follow the
discussion and advisory vote procedure described in the previous section of
these bylaws.

# Releases

The [ASF release process][release-pub] defines the [release
manager][release-manager] as an individual responsible for shepherding a new
project release. Any committer may serve as a release manager by initiating a
release candidate and starting a vote for a release.

At a minimum, a release manager is responsible for packaging a release
candidate for a vote and signing and publishing an approved release candidate.
An Accumulo release manager is also expected to:

* guide whether changes after feature freeze or code freeze should be included in the release
* ensure that required release testing is being conducted
* track whether the release is on target for its expected release date
* adjust release plan dates to reflect the latest estimates
* terminate a release vote by either withdrawing a release candidate from consideration, if needed
* tally the votes and record the vote result after a release vote period has elapsed
* ensure any post-release tasks are performed, such as updating the website and publishing artifacts

Details on [making][making] and [verifying][verifying] a release are available
on the Accumulo website.

# Decision Making

Within the Accumulo project, different types of decisions require different
forms of approval. For example, the previous section describes 'consensus' from
the existing PMC members. Consensus in that case can be achieved through a
[consensus approval vote][consensus].

## Voting

Decisions regarding the project are made by votes on the primary project
development mailing list: dev@accumulo.apache.org. Where necessary, PMC voting
may take place on the private Accumulo PMC mailing list:
private@accumulo.apache.org. Votes are clearly indicated by a subject line
starting with `[VOTE]`. After the vote period has elapsed, the initiator of the
vote, or their designee, closes it by replying to the thread with the vote
results. That result email should use the same subject line preceded by
`[RESULT][VOTE]`. Voting is carried out by replying to the vote mail and
continues until the vote is closed. If a vote thread becomes inactive and
remains open for too long, without a response from the initiator, the PMC Chair
may close the vote.

All participants in the Accumulo project are encouraged to vote. However, some
votes are non-binding (such as votes from non-PMC members during a release
vote). Non-binding votes are still useful to gain insight into the community's
view of the vote topic.

Each person gets only a single vote. You can change your vote by replying to
the same vote thread to explain the change prior to the vote being closed.

For more information on how to vote, see the Foundation's page on
[voting][voting].

The Foundation defines voting criteria for procedural issues, code
modifications, and releases. Most formal votes will be [consensus
approval][consensus]. Release votes, however, follow [majority
approval][majority]. Other decisions, when necessary, can often be made through
[lazy consensus][lazy]. In the case of an objection for a lazy consensus vote,
or the desire for explicit consensus, one can initiate a formal vote thread.

All votes should last a minimum of 72 hours.

## Commit Then Review (CTR)

Accumulo follows a commit-then-review (CTR) policy. This means that consensus
is not required prior to committing. Committers can make changes to the
codebase without seeking approval beforehand, and those changes are assumed to
be approved unless an objection is raised afterwards. Only if an objection is
raised must a vote take place on the code change.

However, just because committers can do this, it does not mean it is always a
good idea. Committers are expected to use their privileges responsibly and to
minimize risks. Therefore, it is often a good idea for committers to seek
feedback through code reviews from the community. Code reviews are our standard
practice and strongly encouraged for anything non-trivial. They are also
strongly encouraged for new committers, even if a change is trivial. If
approval is bypassed, and a problem occurs, committers may be expected to
answer questions about their commit in order to understand what went wrong and
how to avoid problems in the future. So, committers should take care to not
abuse the CTR policy, and to use it sparingly and in ways they can justify.


[committer-faq]: https://www.apache.org/dev/committers
[consensus]: https://www.apache.org/foundation/glossary#ConsensusApproval
[foundation]: https://www.apache.org/foundation
[glossary]: https://www.apache.org/foundation/glossary
[how-it-works]: https://www.apache.org/foundation/how-it-works
[incubator]: https://incubator.apache.org
[lazy]: https://www.apache.org/foundation/glossary#LazyConsensus
[majority]: https://www.apache.org/foundation/glossary#MajorityApproval
[making]: {{ "/contributor/making-release" | relative_url }}
[pmc-guide]: https://www.apache.org/dev/pmc
[release-management]: https://www.apache.org/dev/release#management
[release-manager]: https://www.apache.org/dev/release-publishing#release_manager
[release-pub]: https://www.apache.org/dev/release-publishing
[thisistheway]: https://www.apache.org/theapacheway
[verifying]: {{ "/contributor/verifying-release" | relative_url }}
[voting]: https://www.apache.org/foundation/voting
