---
title: Security Labels
category: security
order: 2
---

Every [Key]-[Value] pair in Accumulo has its own security label, stored under the column visibility
element of the key, which is used to determine whether a given user meets the security
requirements to read the value. This enables data of various security levels to be stored
within the same row, and users of varying degrees of access to query the same table, while
preserving data confidentiality.

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

Scanner s = client.createScanner("table", auths);
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
