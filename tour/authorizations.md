---
title: Authorizations
---

[Authorizations] are a set of Strings that enable a user to read protected data. A [ColumnVisibility] is a boolean expression
that is evaluated using the authorizations provided by a scanner. If it evaluates to true, then the data is visible. 

For example:
* Bob has authorizations `IT, User`
* Tina has authorizations `Admin, IT, User`
* The key `row1:family1:qualifier1` has visibility `Admin && IT && User`
* Bob will **not** see `row1:family1:qualifier1`
* Tina will see `row1:family1:qualifier1`

We now want to secure our secret identities of the heroes so that only users with the proper authorizations can read their names.

1. Using the code from the previous exercise, add the following to the beginning of the _exercise_ method (after we get the Connector).
```java
        // Create a "viewSecretId" authorization & visibility
        final String viewSecretId = "viewSecretId";
        Authorizations secretIdAuth = new Authorizations(viewSecretId);
        ColumnVisibility secretIdVis = new ColumnVisibility(viewSecretId);
        
        // Create a user with the "viewSecretId" authorization and grant him read permissions on our table
        conn.securityOperations().createLocalUser("commissioner", new PasswordToken("gordanrocks"));
        conn.securityOperations().changeUserAuthorizations("commissioner", secretIdAuth);
        conn.securityOperations().grantTablePermission("commissioner", "GothamPD", TablePermission.READ);
```

2. The [Mutation] API allows you to set the `viewSecretId` visibility on a column. Find the proper method for setting a column visibility in
the Mutation API and modify the code so the visibility created above will secure the two "name" columns.

3. Build and run.  What data do you see?
* You should see all of the data except the secret identities of Batman and Robin. This is because the Scanner was created
 from the root user which doesn't have the `viewSecretId` authorization.
* Replace the `Authorizations.EMPTY` in the Scanner with the `secretIdAuth` created above and run it again.
* This should result in an error since the root user doesn't have the authorizations we tried to pass to the Scanner.

4. Get a connector for the "commissioner" and from it create a Scanner with the authorizations needed to view the secret identities.

5. Build and run.  You should see all the rows in the GothamPD table printed, including these secured key/value pairs:
```commandline
Key : id0001 hero:name [viewSecretId] 1511900180231 false         Value : Bruce Wayne
Key : id0002 hero:name [viewSecretId] 1511900180231 false         Value : Dick Grayson
```

[Authorizations]: {{ site.javadoc_core }}/org/apache/accumulo/core/security/Authorizations.html
[ColumnVisibility]: {{ site.javadoc_core }}/org/apache/accumulo/core/security/ColumnVisibility.html
[Mutation]: {{ site.javadoc_core }}/org/apache/accumulo/core/data/Mutation.html
