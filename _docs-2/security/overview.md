---
title: Security Overview
category: security
order: 1
---

This page provides an overview of Accumulo's security features.

A few Accumulo security features have on their own documentation page:

* [Security Labels]({% durl security/labels %})
* [On Disk Encryption]({% durl security/on-disk-encryption %})
* [Wire Encryption]({% durl security/wire-encryption %})
* [Kerberos]({% durl security/kerberos %})

## Pluggable Security

Accumulo has a pluggable security mechanism. It can be broken into three actions: authentication, 
authorization, and permission handling.

Authentication verifies the identity of a user. In Accumulo, authentication occurs when
the `usingToken'` method of the [AccumuloClient] builder is called with a principal (i.e username)
and an [AuthenticationToken] which is an interface with multiple implementations. The most
common implementation is [PasswordToken] which is the default authentication method for Accumulo
out of the box.

```java
AccumuloClient client = Accumulo.newClient()
                    .forInstance("myinstance", "zookeeper1,zookeper2")
                    .usingToken("user", new PasswordToken("passwd")).build();
```

Once a user is authenticated by the Authenticator, the user has access to the other actions within
Accumulo. All actions in Accumulo are ACLed, and this ACL check is handled by the Permission
Handler. This is what manages all of the permissions, which are divided in system and per table
level. From there, if a user is doing an action which requires authorizations, the Authorizor is
queried to determine what authorizations the user has.

This setup allows a variety of different mechanisms to be used for handling different aspects of
Accumulo's security. A system like Kerberos can be used for authentication, then a system like LDAP
could be used to determine if a user has a specific permission, and then it may default back to the
default ZookeeperAuthorizor to determine what Authorizations a user is ultimately allowed to use.
This is a pluggable system so custom components can be created depending on your need.

## Secure Authorizations Handling

For applications serving many users, it is not expected that an Accumulo user
will be created for each application user. In this case an Accumulo user with
all authorizations needed by any of the applications users must be created. To
service queries, the application should create a scanner with the application
user's authorizations. These authorizations could be obtained from a trusted 3rd
party.

Often production systems will integrate with Public-Key Infrastructure (PKI) and
designate client code within the query layer to negotiate with PKI servers in order
to authenticate users and retrieve their authorization tokens (credentials). This
requires users to specify only the information necessary to authenticate themselves
to the system. Once user identity is established, their credentials can be accessed by
the client code and passed to Accumulo outside of the reach of the user.

[AccumuloClient]: {% jurl org.apache.accumulo.core.client.AccumuloClient %}
[AuthenticationToken]: {% jurl org.apache.accumulo.core.client.security.tokens.AuthenticationToken %}
[PasswordToken]: {% jurl org.apache.accumulo.core.client.security.tokens.PasswordToken %}
