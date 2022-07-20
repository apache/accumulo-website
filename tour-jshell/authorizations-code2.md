---
title: Authorizations Code
---

Below is the solution for the previous Authorization exercise. 

For this example, it is best to start with a clean slate. So, if the "GothamPD" table currently 
exists, let's delete and begin fresh.

```commandline
client.tableOperations().delete("GothamPD");
client.securityOperations().dropLocalUser("commissioner"); 
```

Create a table called "GothamPD".
```commandline
jshell> client.tableOperations().create("GothamPD");
```
Create a "secretId" authorization & visibility
```commandline
jshell> String secretId = "secretId";
secretId ==> "secretId"
jshell> Authorizations auths = new Authorizations(secretId);
auths ==> secretId
jshell> ColumnVisibility colVis = new ColumnVisibility(secretId);
colVis ==> [secretId]
```

Create a user with the "secretId" authorization and grant the commissioner read permissions on our table
```commandline
jshell> client.securityOperations().createLocalUser("commissioner", new PasswordToken("gordonrocks"));
jshell> client.securityOperations().changeUserAuthorizations("commissioner", auths);
jshell> client.securityOperations().grantTablePermission("commissioner", "GothamPD", TablePermission.READ);
```

Create three Mutation objects, securing the proper columns.
```commandline
jshell> Mutation mutation1 = new Mutation("id0001");
mutation1 ==> org.apache.accumulo.core.data.Mutation@1
jshell> mutation1.put("hero", "alias", "Batman");
jshell> mutation1.put("hero", "name", colVis, "Bruce Wayne");
jshell> mutation1.put("hero", "wearsCape?", "true");

jshell> Mutation mutation2 = new Mutation("id0002");
mutation2 ==> org.apache.accumulo.core.data.Mutation@1
jshell> mutation2.put("hero", "alias", "Robin");
jshell> mutation2.put("hero", "name", colVis, "Dick Grayson");
jshell> mutation2.put("hero", "wearsCape?", "true");

jshell> Mutation mutation3 = new Mutation("id0003");
mutation3 ==> org.apache.accumulo.core.data.Mutation@1
jshell> mutation3.put("villain", "alias", "Joker");
jshell> mutation3.put("villain", "name", "Unknown");
jshell> mutation3.put("villain", "wearsCape?", "false");
```

Create a BatchWriter to the GothamPD table and add your mutations to it.
Once the BatchWriter is closed the data will be available to scans.

```commandline
jshell> try (BatchWriter writer = client.createBatchWriter("GothamPD")) {
    ...>   writer.addMutation(mutation1);
    ...>   writer.addMutation(mutation2);
    ...>   writer.addMutation(mutation3);
    ...> }
```

Now let's scan.

```commandline
jshell> try (ScannerBase scan = client.createScanner("GothamPD", Authorizations.EMPTY)) {
   ...>   System.out.println("Gotham Police Department Persons of Interest:");
   ...>     for (Map.Entry<Key, Value> entry : scan) {
   ...>     System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>   }
   ...> }
Gotham Police Department Persons of Interest:
Key : id0001 hero:alias [] 1654783465209 false            Value : Batman
Key : id0001 hero:wearsCape? [] 1654783465209 false       Value : true
Key : id0002 hero:alias [] 1654783465209 false            Value : Robin
Key : id0002 hero:wearsCape? [] 1654783465209 false       Value : true
Key : id0003 villain:alias [] 1654783465209 false         Value : Joker
Key : id0003 villain:name [] 1654783465209 false          Value : Unknown
Key : id0003 villain:wearsCape? [] 1654783465209 false    Value : false
```

Note that the default root user can no longer see the name for the two hero's since they are protected
with the `secretId` authorization.

Let's add the `auths` authorization to the default root user and scan again.

```commandline
 jshell> try (ScannerBase scan = client.createScanner("GothamPD", auths)) {
   ...>    System.out.println("Gotham Police Department Persons of Interest:");
   ...>      for (Map.Entry<Key, Value> entry : scan)
   ...>        System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>      }
Gotham Police Department Persons of Interest:
|  Exception java.lang.RuntimeException: org.apache.accumulo.core.client.AccumuloSecurityException: Error BAD_AUTHORIZATIONS for user root on table GothamPD(ID:2) - The user does not have the specified authorizations assigned
|        at ScannerIterator.getNextBatch (ScannerIterator.java:180)
|        at ScannerIterator.hasNext (ScannerIterator.java:105)
|        at (#54:3)
|  Caused by: org.apache.accumulo.core.client.AccumuloSecurityException: Error BAD_AUTHORIZATIONS for user root on table GothamPD(ID:2) - The user does not have the specified authorizations assigned
|        at ThriftScanner.scan (ThriftScanner.java:574)
|        at ThriftScanner.scan (ThriftScanner.java:326)
|        at ScannerIterator.readBatch (ScannerIterator.java:151)
|        at ScannerIterator.getNextBatch (ScannerIterator.java:169)
|        ...
|  Caused by: org.apache.accumulo.core.clientImpl.thrift.ThriftSecurityException
|        at TabletScanClientService$startScan_result$startScan_resultStandardScheme.read (TabletScanClientService.java:4233)
|        at TabletScanClientService$startScan_result$startScan_resultStandardScheme.read (TabletScanClientService.java:4210)
|        at TabletScanClientService$startScan_result.read (TabletScanClientService.java:4125)
|        at TServiceClient.receiveBase (TServiceClient.java:88)
|        at TabletScanClientService$Client.recv_startScan (TabletScanClientService.java:117)
|        at TabletScanClientService$Client.startScan (TabletScanClientService.java:89)
|        at ThriftScanner.scan (ThriftScanner.java:483)
|        ...
 
```

This results in an error since the root user doesn't have the authorizations we tried to pass to the Scanner

Now, create a second client for the commissioner user and output all the rows visible to them.
Make sure to pass the proper authorizations.

```commandline
jshell> try (AccumuloClient commishClient = Accumulo.newClient().from(client.properties()).as("commissioner", "gordonrocks").build()) {
   ...>   try (ScannerBase scan = commishClient.createScanner("GothamPD", auths)) {
   ...>     System.out.println("Gotham Police Department Persons of Interest:");
   ...>     for (Map.Entry<Key, Value> entry : scan) {
   ...>       System.out.printf("Key : %-50s  Value : %s\n", entry.getKey(), entry.getValue());
   ...>     }
   ...>   } 
   ...> }
```

The solution above will print (timestamp will differ):

```commandline
Gotham Police Department Persons of Interest:
Key : id0001 hero:alias [] 1654106385737 false            Value : Batman
Key : id0001 hero:name [secretId] 1654106385737 false     Value : Bruce Wayne
Key : id0001 hero:wearsCape? [] 1654106385737 false       Value : true
Key : id0002 hero:alias [] 1654106385737 false            Value : Robin
Key : id0002 hero:name [secretId] 1654106385737 false     Value : Dick Grayson
Key : id0002 hero:wearsCape? [] 1654106385737 false       Value : true
Key : id0003 villain:alias [] 1654106385737 false         Value : Joker
Key : id0003 villain:name [] 1654106385737 false          Value : Unknown
Key : id0003 villain:wearsCape? [] 1654106385737 false    Value : false
```



