---
title: Permissions
category: security
order: 3
---

Accumulo users can only perform actions if they are given permission.

Accumulo has three types of permissions:

* [SystemPermission]
* [NamespacePermission]
* [TablePermission]

These permissions are managed by [SecurityOperations] in Java API or the [Accumulo shell][shell].

## Configuration

Accumulo's [PermissionHandler] is configured by setting {% plink instance.security.permissionHandler %}.

The default permission handler is described below.

## Granting permission

Users can be granted permissions in the shell:

```
root@uno> grant System.CREATE_TABLE -s -u bob
```

Or in the Java API using [SecurityOperations]:

```java
client.securityOperations().grantSystem("bob", SystemPermission.CREATE_TABLE);
```

## View permissions

Permissions can be listed for a user in the shell:

```
root@uno> userpermissions -u bob
System permissions: System.CREATE_TABLE, System.DROP_TABLE

Namespace permissions (accumulo): Namespace.READ

Table permissions (accumulo.metadata): Table.READ
Table permissions (accumulo.replication): Table.READ
Table permissions (accumulo.root): Table.READ
```

## Revoking permissions

Permissions can be revoked for a user in the shell

```
root@uno> revoke System.CREATE_TABLE -s -u bob
```

Or in the Java API using [SecurityOperations]:

```java
client.securityOperations().revokeSystemPermission("bob", SystemPermission.CREATE_TABLE);
```

[shell]: {% durl getting-started/shell %}
[PermissionHandler]: {% jurl org.apache.accumulo.server.security.handler.PermissionHandler %}
[SystemPermission]: {% jurl org.apache.accumulo.core.security.SystemPermission %}
[NamespacePermission]: {% jurl org.apache.accumulo.core.security.NamespacePermission %}
[TablePermission]: {% jurl org.apache.accumulo.core.security.TablePermission %}
[SecurityOperations]: {% jurl org.apache.accumulo.core.client.admin.SecurityOperations %}

