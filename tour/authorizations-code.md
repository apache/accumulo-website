---
title: Authorizations Code
---

Below is a solution for the exercise.

```java
static void exercise(MiniAccumuloCluster mac) throws Exception {
    // Connect to Mini Accumulo as the root user and create a table called "GothamPD".
    Connector conn = mac.getConnector("root", "tourguide");
    conn.tableOperations().create("GothamPD");

    // Create a "secretId" authorization & visibility
    final String secretId = "secretId";
    Authorizations auths = new Authorizations(secretId);
    ColumnVisibility colVis = new ColumnVisibility(secretId);

    // Create a user with the "secretId" authorization and grant him read permissions on our table
    conn.securityOperations().createLocalUser("commissioner", new PasswordToken("gordanrocks"));
    conn.securityOperations().changeUserAuthorizations("commissioner", auths);
    conn.securityOperations().grantTablePermission("commissioner", "GothamPD", TablePermission.READ);

    // Create 3 Mutation objects, securing the proper columns.
    Mutation mutation1 = new Mutation("id0001");
    mutation1.put("hero","alias", "Batman");
    mutation1.put("hero","name", colVis, "Bruce Wayne");
    mutation1.put("hero","wearsCape?", "true");
    Mutation mutation2 = new Mutation("id0002");
    mutation2.put("hero","alias", "Robin");
    mutation2.put("hero","name", colVis,"Dick Grayson");
    mutation2.put("hero","wearsCape?", "true");
    Mutation mutation3 = new Mutation("id0003");
    mutation3.put("villain","alias", "Joker");
    mutation3.put("villain","name", "Unknown");
    mutation3.put("villain","wearsCape?", "false");

    // Create a BatchWriter to the GothamPD table and add your mutations to it.
    // Once the BatchWriter is closed by the try w/ resources, data will be available to scans.
    try (BatchWriter writer = conn.createBatchWriter("GothamPD", new BatchWriterConfig())) {
        writer.addMutation(mutation1);
        writer.addMutation(mutation2);
        writer.addMutation(mutation3);
    }

    // Read and print all rows of the commissioner can see. Pass Scanner proper authorizations
    Connector commishConn = mac.getConnector("commissioner", "gordanrocks");
    try (Scanner scan = commishConn.createScanner("GothamPD", auths)) {
        System.out.println("Gotham Police Department Persons of Interest:");
        for (Map.Entry<Key, Value> entry : scan) {
            System.out.printf("Key : %-60s  Value : %s\n", entry.getKey(), entry.getValue());
        }
    }
}
```

The solution above will print (timestamp will differ):

```commandline
Gotham Police Department Persons of Interest:
Key : id0001 hero:alias [] 1511900180231 false                      Value : Batman
Key : id0001 hero:name [secretId] 1511900180231 false               Value : Bruce Wayne
Key : id0001 hero:wearsCape? [] 1511900180231 false                 Value : true
Key : id0002 hero:alias [] 1511900180231 false                      Value : Robin
Key : id0002 hero:name [secretId] 1511900180231 false               Value : Dick Grayson
Key : id0002 hero:wearsCape? [] 1511900180231 false                 Value : true
Key : id0003 villain:alias [] 1511900180231 false                   Value : Joker
Key : id0003 villain:name [] 1511900180231 false                    Value : Unknown
Key : id0003 villain:wearsCape? [] 1511900180231 false              Value : false
```
