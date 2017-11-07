---
title: Authorizations
---
An Authorization is an authority granted to a User that allows them to read certain data. A column in Accumulo can have 
a visibility attached to it, limiting access to the data of that column. Only users who have an authorization equal to 
the visibility will be able to read the data in that column.

We now want to secure our secret identities of the heroes so that only users with the proper authorizations can read their names.

1. Using the code from the previous exercise, add the following to the beginning of the _exercise_ method (after we get the Connector).
```java
        // Create a "secretIdentity" authorization & visibility
        final String secId = "secretIdentity";
        Authorizations auths = new Authorizations(secId);
        ColumnVisibility visibility = new ColumnVisibility(secId);
        
        // Create a user with the "secretIdentity" authorization and grant him read permissions on our table
        conn.securityOperations().createLocalUser("commissioner", new PasswordToken("gordanrocks"));
        conn.securityOperations().changeUserAuthorizations("commissioner", auths);
        conn.securityOperations().grantTablePermission("commissioner", "GothamPD", TablePermission.READ);
``` 

2. The Mutation API allows you to set the visibility on a column. Find the proper method for setting a column visibility in 
the [Mutation API][mut] and modify the code so the visibility created above will secure the two "name" columns. 

3. Build and run.  What data do you see?
* You should see all of the data except the secret identities of Batman and Robin.  This is because the Scanner was created
 from the root user Connector.  
* Replace the _Authorizations.EMPTY_ in the Scanner with the _auths_ created above and run it again.
* This should result in an error since the root user doesn't have the authorizations we tried to pass to the Scanner.

4. Get a connector for the "commissioner" and from it create a Scanner with the authorizations needed to view the secret identities.

5. Build and run.  You should see all the rows in the GothamPD table printed, including these secured key/value pairs:
```commandline
Key:id0001 hero:name [secretIdentity] 1510092746436 false
Value:Bruce Wayne
Key:id0002 hero:name [secretIdentity] 1510092746436 false
Value:Dick Grayson
```

[mut]: https://accumulo.apache.org/1.8/apidocs/org/apache/accumulo/core/data/Mutation.html