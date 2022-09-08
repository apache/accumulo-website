---
title: ZooKeeper
category: troubleshooting
order: 7
---

## ACL errors during upgrade

Manual intervention is required in the event that an upgrade fails due to unexpected znode ACLs. To resolve this issue ZooKeeper will need to be restarted with an additional property to bypass existing ACLs so that the ACLs can be fixed. Specifically, the `DigestAuthenticationProvider.superDigest` ZooKeeper Authentication [option] needs to be set so that you can log into the ZooKeeper shell and fix the ACLs. The steps for this are:

    1. Stop ZooKeeper
    2. Run the following from ZOOKEEPER_HOME replacing `$secret` with some value:
    ```
    export CLASSPATH="lib/*"
    java org.apache.zookeeper.server.auth.DigestAuthenticationProvider accumulo:$secret
    ```
    3. Add the following to zoo.cfg replacing `$digest` with the digest value returned from step 2:
    ```
    DigestAuthenticationProvider.superDigest=accumulo:$digest
    ```
    4. Restart ZooKeeper
    5. Log into ZooKeeper using the `zkCli` and run `addauth digest accumulo:$secret` using the secret from step 2.
    6. Then, correct the ACL on the znode using the command `setAcl -R <path> world:anyone:r,auth:accumulo:cdrwa`

[option]: https://zookeeper.apache.org/doc/r3.5.2-alpha/zookeeperAdmin.html#sc_authOptions

