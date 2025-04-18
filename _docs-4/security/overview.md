---
title: Security Overview
category: security
order: 1
---

Accumulo has the following security features:

* Only [authenticated][Authentication] users can access Accumulo.
  * [Kerberos] can be enabled to replace Accumulo's default, password-based authentication
* Users can only perform actions if they are given [permission][Permissions].
* Users can only view [labeled data]({% durl security/authorizations#security-labels %}) that they are [authorized][Authorizations] to see.
* Data can be encrypted [on disk]({% durl security/on-disk-encryption %}) and [over-the-wire]({% durl security/wire-encryption %})

## Implementation

Below is a description of how security is implemented in Accumulo.

Once a user is authenticated by the [Authenticator], the user has access to the other actions within
Accumulo. All actions in Accumulo are ACLed, and this ACL check is handled by the [PermissionHandler].
This is what manages all of the [permissions], which are divided in system and per table
level. From there, if a user is doing an action which requires authorizations, the [Authorizor] is
queried to determine what authorizations the user has.

This setup allows a variety of different mechanisms to be used for handling different aspects of
Accumulo's security. A system like [Kerberos] can be used for [authentication], then a system like LDAP
could be used to determine if a user has a specific permission, and then it may default back to the
default [Authorizor] to determine what Authorizations a user is ultimately allowed to use.
This is a pluggable system so custom components can be created depending on your need.

[Kerberos]: {% durl security/kerberos %}
[authentication]: {% durl security/authentication %}
[authorizations]: {% durl security/authorizations %}
[permissions]: {% durl security/permissions %}
[Authenticator]: {% jurl org.apache.accumulo.server.security.handler.Authenticator %}
[Authorizor]: {% jurl org.apache.accumulo.server.security.handler.Authorizor %}
[PermissionHandler]: {% jurl org.apache.accumulo.server.security.handler.PermissionHandler %}
