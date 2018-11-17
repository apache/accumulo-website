---
title: Authentication
category: security
order: 2
---

Accumulo has authentication to verify the identity of users.

## Configuration

Accumulo can be configured to use different authentication methods:

| Method  | Setting for {% plink instance.security.authenticator %} |
|---------|---------|
| Password **(default)** | {% jlink -f org.apache.accumulo.server.security.handler.ZKAuthenticator %} |
| [Kerberos]({% durl security/kerberos %}) | {% jlink -f org.apache.accumulo.server.security.handler.KerberosAuthenticator %} |

All authentication methods implement [Authenticator]. The default (password-based) implementation method is described in this document.

## Root user

When [Accumulo is initialized]({% durl getting-started/quickstart#initialization %}), a `root` user is created and given
a password.  This `root` user is used to create other users. 

## Creating users

Users can be created in the shell:

```
root@uno> createuser bob
Enter new password for 'bob': ****
Please confirm new password for 'bob': ****
```

In the Java API using [SecurityOperations]:

```java
client.securityOperations().createLocalUser("bob", new PasswordToken("pass"));
```

## Authenticating users

Users are authenticated when they [create an Accumulo client]({% durl getting-started/clients#creating-an-accumulo-client %})
or when the log in to the [Accumulo shell]({% durl getting-started/shell %}).

Authentication can also be tested in the shell:

```
root@myinstance mytable> authenticate bob
Enter current password for 'bob': ****
Valid
```

In the Java API using [SecurityOperations]:

```java
boolean valid = client.securityOperations().authenticateUser("bob", new PasswordToken("pass"));
```

## Changing user passwords

A user's password can changed be in the shell:

```
root@uno> passwd -u bob
Enter current password for 'root': ******
Enter new password for 'bob': ***
```

In the Java API using [SecurityOperations]:

```java
client.securityOperations().changeLocalUserPassword("bob", new PasswordToken("pass"));
```

## Removing users

Users can be removed in the shell:

```
root@uno> dropuser bob
dropuser { bob } (yes|no)? yes
```

In the Java API using [SecurityOperations]:

```java
client.securityOperations().dropLocalUser("bob");
```

[Authenticator]: {% jurl org.apache.accumulo.server.security.handler.Authenticator %}
[SecurityOperations]: {% jurl org.apache.accumulo.core.client.admin.SecurityOperations %}
