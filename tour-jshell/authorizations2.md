---
title: Authorizations
---

[Authorizations] are a set of `String`'s that enable a user to read protected data. Users are granted 
authorizations and choose which ones to use when scanning a table. The chosen authorizations are evaluated 
against the [ColumnVisibility] of each Accumulo key in the scan. If the boolean expression of the 
ColumnVisibility evaluates to true, the data will be visible to the user.

For example:
* Bob has authorizations `product, sales`
* Tina has authorizations `sales, employee`
* The key `row1:family1:qualifier1` has visibility `sales && employee`
* When Bob scans with all of his authorizations, he will **not** see `row1:family1:qualifier1`
* When Tina scans with all of her authorizations, she will see `row1:family1:qualifier1`

For the next exercise we want to secure our secret identities of the heroes so that only users with 
the proper authorizations can read their names.

Create a "secretId" authorization & visibility.

```commandline
jshell> String secretId = "secretId";
secretId ==> "secretId"

jshell> Authorizations auths = new Authorizations(secretId);
auths ==> secretId

jshell> ColumnVisibility colVis = new ColumnVisibility(secretId);
colVis ==> [secretId]
```

Create a user with the "secretId" authorization and grant read permissions on our table.

```commandline
jshell> client.securityOperations().createLocalUser("commissioner", new PasswordToken("gordonrocks"));
jshell> client.securityOperations().changeUserAuthorizations("commissioner", auths);
jshell> client.securityOperations().grantTablePermission("commissioner", "GothamPD", TablePermission.READ);
```

The [Mutation] API allows you to set the `secretId` visibility on a column. Find the proper method for 
setting a column visibility in the Mutation API and modify the code so the `colVis` variable created 
above secures the "name" columns.

What data do you see?

* You should see all the data except the secret identities of Batman and Robin. This is because the 
`Scanner` was created from the root user which doesn't have the `secretId` authorization.
* Replace the `Authorizations.EMPTY` in the Scanner with the `auths` variable created above and run 
it again. This should result in an error since the root user doesn't have the authorizations we 
tried to pass to the Scanner.

Next, create a client for the "commissioner". Using the commissioner client, create a Scanner with the 
authorizations needed to view the secret identities. You should see all the rows in the GothamPD table 
printed, including the secured key/value pairs:


[Authorizations]: {% jurl org.apache.accumulo.core.security.Authorizations %}
[ColumnVisibility]: {% jurl org.apache.accumulo.core.security.ColumnVisibility %}
[Mutation]: {% jurl org.apache.accumulo.core.data.Mutation %}
[Accumulo]: {% jurl org.apache.accumulo.core.client.Accumulo %}
