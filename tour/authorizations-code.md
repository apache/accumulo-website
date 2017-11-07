---
title: Authorizations Code
---
```java
        // Connect to Mini Accumulo as the root user and create a table called "GothamPD".
        Connector conn = mac.getConnector("root", "tourguide");
        conn.tableOperations().create("GothamPD");

        // Create a "secretIdentity" authorization & visibility
        final String secId = "secretIdentity";
        Authorizations auths = new Authorizations(secId);
        ColumnVisibility visibility = new ColumnVisibility(secId);

        // Create a user with the "secretIdentity" authorization and grant him read permissions on our table
        conn.securityOperations().createLocalUser("commissioner", new PasswordToken("gordanrocks"));
        conn.securityOperations().changeUserAuthorizations("commissioner", auths);
        conn.securityOperations().grantTablePermission("commissioner", "GothamPD", TablePermission.READ);

        // Create 3 Mutation objects to hold each person of interest.
        Mutation mutation1 = new Mutation("id0001");
        Mutation mutation2 = new Mutation("id0002");
        Mutation mutation3 = new Mutation("id0003");

        // Create key/value pairs for each Mutation, putting them in the appropriate family.
        mutation1.put("hero","alias", "Batman");
        mutation1.put("hero","name", visibility,"Bruce Wayne");
        mutation1.put("hero","wearsCape?", "true");
        mutation2.put("hero","alias", "Robin");
        mutation2.put("hero","name", visibility,"Dick Grayson");
        mutation2.put("hero","wearsCape?", "true");
        mutation3.put("villain","alias", "Joker");
        mutation3.put("villain","name", "Unknown");
        mutation3.put("villain","wearsCape?", "false");

        // Create a BatchWriter to the GothamPD table and add your mutations to it.  Try w/ resources will close for us.
        try(BatchWriter writer = conn.createBatchWriter("GothamPD", new BatchWriterConfig())) {
            writer.addMutation(mutation1);
            writer.addMutation(mutation2);
            writer.addMutation(mutation3);
        }

        // Read and print all rows of the commissioner can see. Pass Scanner proper authorizations
        Connector commishConn = mac.getConnector("commissioner", "gordanrocks");
        try(Scanner scan = commishConn.createScanner("GothamPD", auths)) {
            System.out.println("Gotham Police Department Persons of Interest:");
            for (Map.Entry<Key, Value> entry : scan) {
                System.out.println("Key:" + entry.getKey());
                System.out.println("Value:" + entry.getValue());
            }
        }
```