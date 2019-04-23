---
title: Authorizations
category: security
order: 4
---

In Accumulo, data is written with [security labels] that limit access to only users with the proper
[authorizations][auths].

## Configuration

Accumulo's [Authorizor] is configured by setting {% plink instance.security.authorizor %}. The default
authorizor is the {% jlink org.apache.accumulo.server.security.handler.ZKAuthorizor %} which is described
below.

## Security Labels

Every [Key]-[Value] pair in Accumulo has its own security label, stored under the column visibility
element of the key, which is used to determine whether a given user meets the security
requirements to read the value. This enables data of various security levels to be stored
within the same row, and users of varying degrees of access to query the same table, while
preserving data confidentiality.

### Writing labeled data

When [writing data to Accumulo]({% durl getting-started/clients#writing-data %}), users can
specify a security label for each value by passing a [ColumnVisibilty] to the [Mutation].

```java
try (BatchWriter writer = client.createBatchWriter("employees")) {
  Mutation mut = new Mutation("employee1");
  mut.at().family("pay").qualifier("salary").visibility("payroll").value("50000");
  mut.at().family("pay").qualifier("period").visibility("public").value("monthly");
  writer.addMutation(mut)
}
```

### Security Label Expression Syntax

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

Scanner s = client.createScanner("table", auths);
```

### User Authorizations

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

### Advanced Authorizations Handling

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

[security labels]: {% durl security/authorizations#security-labels %}
[auths]: {% durl security/authorizations#authorizations %}
[shell]: {% durl getting-started/shell %}
[Key]: {% jurl org.apache.accumulo.core.data.Key %}
[Value]: {% jurl org.apache.accumulo.core.data.Value %}
[Mutation]: {% jurl org.apache.accumulo.core.data.Mutation %}
[ColumnVisibility]: {% jurl org.apache.accumulo.core.security.ColumnVisibility %}
[Scanner]: {% jurl org.apache.accumulo.core.client.Scanner %}
[AccumuloClient]: {% jurl org.apache.accumulo.core.client.AccumuloClient %}
[BatchScanner]: {% jurl org.apache.accumulo.core.client.BatchScanner %}
[Authorizations]: {% jurl org.apache.accumulo.core.security.Authorizations %}
[SecurityOperations]: {% jurl org.apache.accumulo.core.client.admin.SecurityOperations %}
[Instance]: {% jurl org.apache.accumulo.core.client.Instance %}
[AuthenticationToken]: {% jurl org.apache.accumulo.core.client.security.tokens.AuthenticationToken %}
[PasswordToken]: {% jurl org.apache.accumulo.core.client.security.tokens.PasswordToken %}
[Authorizor]: {% jurl org.apache.accumulo.server.security.handler.Authorizor %}
