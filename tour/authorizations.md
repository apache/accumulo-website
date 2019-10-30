---
title: Authorizations
---

[Authorizations] are a set of Strings that enable a user to read protected data. Users are granted authorizations
and choose which ones to use when scanning a table. The chosen authorizations are evaluated against the [ColumnVisibility]
of each Accumulo key in the scan. If the boolean expression of the ColumnVisibility evaluates to true, the data will be
visible to the user.

For example:
* Bob has authorizations `product, sales`
* Tina has authorizations `sales, employee`
* The key `row1:family1:qualifier1` has visibility `sales && employee`
* When Bob scans with all of his authorizations, he will **not** see `row1:family1:qualifier1`
* When Tina scans with all of her authorizations, she will see `row1:family1:qualifier1`

We now want to secure our secret identities of the heroes so that only users with the proper authorizations can read their names.

1. Using the code from the previous exercise, add the following to the beginning of the _exercise_ method.
```java
        // Create a "secretId" authorization & visibility
        final String secretId = "secretId";
        Authorizations auths = new Authorizations(secretId);
        ColumnVisibility colVis = new ColumnVisibility(secretId);
        
        // Create a user with the "secretId" authorization and grant him read permissions on our table
        client.securityOperations().createLocalUser("commissioner", new PasswordToken("gordonrocks"));
        client.securityOperations().changeUserAuthorizations("commissioner", auths);
        client.securityOperations().grantTablePermission("commissioner", "GothamPD", TablePermission.READ);
```

2. The [Mutation] API allows you to set the `secretId` visibility on a column. Find the proper method for setting a column visibility in
the Mutation API and modify the code so the `colVis` variable created above secures the "name" columns.

3. Build and run.  What data do you see?
* You should see all of the data except the secret identities of Batman and Robin. This is because the Scanner was created
 from the root user which doesn't have the `secretId` authorization.
* Replace the `Authorizations.EMPTY` in the Scanner with the `auths` variable created above and run it again.
* This should result in an error since the root user doesn't have the authorizations we tried to pass to the Scanner.

4. Use the following to create a client for the "commissioner" using the [Accumulo] entry point.
```java
try (AccumuloClient commishClient = Accumulo.newClient().from(client.properties())
    .as("commissioner", "gordonrocks").build();
```

5. Using the commissioner client, create a Scanner with the authorizations needed to view the secret identities.

6. Build and run.  You should see all the rows in the GothamPD table printed, including these secured key/value pairs:
```commandline
Key : id0001 hero:name [secretId] 1511900180231 false         Value : Bruce Wayne
Key : id0002 hero:name [secretId] 1511900180231 false         Value : Dick Grayson
```

[Authorizations]: {% jurl org.apache.accumulo.core.security.Authorizations %}
[ColumnVisibility]: {% jurl org.apache.accumulo.core.security.ColumnVisibility %}
[Mutation]: {% jurl org.apache.accumulo.core.data.Mutation %}
[Accumulo]: {% jurl org.apache.accumulo.core.client.Accumulo %}
