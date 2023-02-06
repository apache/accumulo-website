---
title: ZooKeeper
category: troubleshooting
order: 7
---
## ZooKeeper ACLs

Accumulo requires full access to nodes in ZooKeeper under the /accumulo path.  The ACLs can be examined using the
ZooKeeper cli `getAcl` and modified with `setAcl` commands.  With 2.1.1, the zoo-info-viewer utility has an option
that will print all of the ACLs for the nodes under `/accumulo/[INSTANCE_ID]` (See [zoo-info-viewer]).  
To run the utility, only ZooKeeper needs to be running. If hdfs is running, the instance id can be read from hdfs, 
or it can be entered with the zoo-info-viewer command --instanceId option.  Accumulo management processes 
*do not* need to be running. This allows checking the ACLs before starting an upgrade.

The utility also prints the same permissions and user strings as the ZooKeeper cli getAcl command, so you can
fully evaluate the permissions in the context of your needs.  

Sample output (See the [zoo-info-viewer] tools documentation for a more complete sample):
```
ACCUMULO_OKAY:NOT_PRIVATE /accumulo/f491223b-1413-494e-b75a-c2ca018db00f cdrwa:accumulo, r:anyone
ACCUMULO_OKAY:PRIVATE /accumulo/f491223b-1413-494e-b75a-c2ca018db00f/config cdrwa:accumulo
ERROR_ACCUMULO_MISSING_SOME:NOT_PRIVATE /accumulo/f491223b-1413-494e-b75a-c2ca018db00f/users/root/Namespaces r:accumulo, r:anyone
```
The utility prints out a line for each znode that contains two fields related to ZooKeeper ACL permissions:
   - `[ACCUMULO_OKAY | ERROR_ACCUMULO_MISSING_SOME]` - Are the permissions sufficient for Accumulo to operate 
   - `[PRIVATE | NOT_PRIVATE]` - Can other users can read data from the ZooKeeper nodes.

Nodes marked with `ERROR_ACCUMULO_MISSING_SOME` shows that Accumulo does not have `cdrwa` permissions.
Without full permissions, the upgrade will fail checks. The node permissions need to be corrected with the ZooKeeper
`setAcl` command.  If you do not have sufficient permissions to change the ACLs on a node, see the section 
below, [ACL errors during upgrade]({% durl troubleshooting/zookeeper/ACL#errors#during#upgrade %}).

Most Accumulo nodes do not contain sensitive data. Allowing unauthenticated ZooKeeper client(s) to read values is 
not unusual in typical deployments. The exception to a permissive read policy are the nodes that store configuration 
and properties (generally, nodes named `../config`). Because property values may be sensitive, access should be
restricted to authenticated Accumulo clients.  The tool will mark those nodes as `PRIVATE`.

Allowing users other than authenticated Accumulo clients to write or modify nodes is not recommended.

The utility also prints the same permissions and user strings as the ZooKeeper cli getAcl command, so you can 
fully evaluate the permissions in the context of your needs.  See the [zoo-info-viewer] tools documentation 
for sample output.

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
[tools-info-viewer]: {% durl troubleshooting/tools#mode-print-ACLs %}

