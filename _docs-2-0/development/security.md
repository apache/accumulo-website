---
title: Security
category: development
order: 7
---

Accumulo extends the BigTable data model to implement a security mechanism
known as cell-level security. Every [Key]-[Value] pair has its own security label, stored
under the column visibility element of the key, which is used to determine whether
a given user meets the security requirements to read the value. This enables data of
various security levels to be stored within the same row, and users of varying
degrees of access to query the same table, while preserving data confidentiality.

## Security Label Expressions

When mutations are applied, users can specify a security label for each value. This is
done as the [Mutation] is created by passing a [ColumnVisibility] object to the put()
method:

```java
Text rowID = new Text("row1");
Text colFam = new Text("myColFam");
Text colQual = new Text("myColQual");
ColumnVisibility colVis = new ColumnVisibility("public");
long timestamp = System.currentTimeMillis();

Value value = new Value("myValue");

Mutation mutation = new Mutation(rowID);
mutation.put(colFam, colQual, colVis, timestamp, value);
```

## Security Label Expression Syntax

Security labels consist of a set of user-defined tokens that are required to read the
value the label is associated with. The set of tokens required can be specified using
syntax that supports logical AND `&` and OR `|` combinations of terms, as
well as nesting groups `()` of terms together.

Each term is comprised of one to many alpha-numeric characters, hyphens, underscores or
periods. Optionally, each term may be wrapped in quotation marks
which removes the restriction on valid characters. In quoted terms, quotation marks
and backslash characters can be used as characters in the term by escaping them
with a backslash.

For example, suppose within our organization we want to label our data values with
security labels defined in terms of user roles. We might have tokens such as:

    admin
    audit
    system

These can be specified alone or combined using logical operators:

```
// Users must have admin privileges
admin

// Users must have admin and audit privileges
admin&audit

// Users with either admin or audit privileges
admin|audit

// Users must have audit and one or both of admin or system
(admin|system)&audit
```

When both `|` and `&` operators are used, parentheses must be used to specify
precedence of the operators.

## Authorizations

When clients attempt to read data from Accumulo, any security labels present are
examined against an [Authorizations] object passed by the client code when the
[Scanner] or [BatchScanner] are created. If the Authorizations are determined to be
insufficient to satisfy the security label, the value is suppressed from the set of
results sent back to the client.

[Authorizations] are specified as a comma-separated list of tokens the user possesses:

```java
// user possesses both admin and system level access
Authorizations auths = new Authorizations("admin","system");

Scanner s = connector.createScanner("table", auths);
```

## User Authorizations

Each Accumulo user has a set of associated security labels. To manipulate these in
the [Accumulo shell][shell], use the `setuaths` and `getauths` commands. They can be
retrieved and modified in Java using `getUserAuthorizations` and `changeUserAuthorizations`
methods of [SecurityOperations].

When a user creates a [Scanner] or [BatchScanner] a set of [Authorizations] is passed.
If the Authorizations passed to the scanner are not a subset of the user's Authorizations,
then an exception will be thrown.

To prevent users from writing data they can not read, add the visibility
constraint to a table. Use the -evc option in the `createtable` shell command to
enable this constraint. For existing tables, use the `config` command to
enable the visibility constraint. Ensure the constraint number does not
conflict with any existing constraints.

    config -t table -s table.constraint.1=org.apache.accumulo.core.security.VisibilityConstraint

Any user with the alter table permission can add or remove this constraint.
This constraint is not applied to bulk imported data, if this a concern then
disable the bulk import permission.

## Pluggable Security

Accumulo has a pluggable security mechanism. It can be broken into three actions: authentication, 
authorization, and permission handling.

Authentication verifies the identity of a user. In Accumulo, authentication occurs when
the `usingCredentials'` method of the [Connector] builder is called with a principal (i.e username)
and an [AuthenticationToken] which is an interface with multiple implementations. The most
common implementation is [PasswordToken] which is the default authentication method for Accumulo
out of the box.

```java
Connector conn = Connector.builder().forInstance("myinstance", "zookeeper1,zookeper2")
                    .usingPasswordCredentials("user", "passwd").build();
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

## Query Services Layer

Since the primary method of interaction with Accumulo is through the Java API,
production environments often call for the implementation of a Query layer. This
can be done using web services in containers such as Apache Tomcat, but is not a
requirement. The Query Services Layer provides a mechanism for providing a
platform on which user facing applications can be built. This allows the application
designers to isolate potentially complex query logic, and enables a convenient point
at which to perform essential security functions.

Several production environments choose to implement authentication at this layer,
where users identifiers are used to retrieve their access credentials which are then
cached within the query layer and presented to Accumulo through the
Authorizations mechanism.

Typically, the query services layer sits between Accumulo and user workstations.

[shell]: {{ page.docs_baseurl }}/getting-started/shell
[Key]: {{ page.javadoc_core }}/org/apache/accumulo/core/data/Key.html
[Value]: {{ page.javadoc_core }}/org/apache/accumulo/core/data/Value.html
[Mutation]: {{ page.javadoc_core }}/org/apache/accumulo/core/data/Mutation.html
[ColumnVisibility]: {{ page.javadoc_core }}/org/apache/accumulo/core/security/ColumnVisibility.html
[Scanner]: {{ page.javadoc_core }}/org/apache/accumulo/core/client/Scanner.html
[BatchScanner]: {{ page.javadoc_core}}/org/apache/accumulo/core/client/BatchScanner.html
[Authorizations]: {{ page.javadoc_core}}/org/apache/accumulo/core/security/Authorizations.html
[SecurityOperations]: {{ page.javadoc_core}}/org/apache/accumulo/core/client/admin/SecurityOperations.html
[Instance]: {{ page.javadoc_core}}/org/apache/accumulo/core/client/Instance.html
[AuthenticationToken]: {{ page.javadoc_core}}/org/apache/accumulo/core/client/security/tokens/AuthenticationToken.html
[PasswordToken]: {{ page.javadoc_core}}/org/apache/accumulo/core/client/security/tokens/PasswordToken.html
