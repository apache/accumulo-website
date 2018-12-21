---
title: System Metadata Tables
category: troubleshooting
order: 4
---

Accumulo tracks information about tables in metadata tables. The metadata for
most tables is contained within the metadata table in the accumulo namespace,
while metadata for that table is contained in the root table in the accumulo
namespace. The root table is composed of a single tablet, which does not
split, so it is also called the root tablet. Information about the root
table, such as its location and write-ahead logs, are stored in ZooKeeper.

Let's create a table and put some data into it:

```
shell> createtable test

shell> tables -l
accumulo.metadata    =>        !0
accumulo.root        =>        `r
test                 =>         2
trace                =>         1

shell> insert a b c d

shell> flush -w
```

Now let's take a look at the metadata for this table:

    shell> table accumulo.metadata
    shell> scan -b 3; -e 3<
    3< file:/default_tablet/F000009y.rf []    186,1
    3< last:13fe86cd27101e5 []    127.0.0.1:9997
    3< loc:13fe86cd27101e5 []    127.0.0.1:9997
    3< srv:dir []    /default_tablet
    3< srv:flush []    1
    3< srv:lock []    tservers/127.0.0.1:9997/zlock-0000000001$13fe86cd27101e5
    3< srv:time []    M1373998392323
    3< ~tab:~pr []    \x00

Let's decode this little session:

* `scan -b 3; -e 3<` -   Every tablet gets its own row. Every row starts with the table id followed by
    `;` or `<`, and followed by the end row split point for that tablet.

* `file:/default_tablet/F000009y.rf [] 186,1` -
    File entry for this tablet.  This tablet contains a single file reference. The
    file is `/accumulo/tables/3/default_tablet/F000009y.rf`.  It contains 1
    key/value pair, and is 186 bytes long.

* `last:13fe86cd27101e5 []    127.0.0.1:9997` -
    Last location for this tablet.  It was last held on 127.0.0.1:9997, and the
    unique tablet server lock data was `13fe86cd27101e5`. The default balancer
    will tend to put tablets back on their last location.

* `loc:13fe86cd27101e5 []    127.0.0.1:9997` -
    The current location of this tablet.

* `srv:dir []    /default_tablet` -
    Files written for this tablet will be placed into
    `/accumulo/tables/3/default_tablet`.

* `srv:flush []    1` -
    Flush id.  This table has successfully completed the flush with the id of `1`.

* `srv:lock []    tservers/127.0.0.1:9997/zlock-0000000001\$13fe86cd27101e5` -
    This is the lock information for the tablet holding the present lock.  This
    information is checked against zookeeper whenever this is updated, which
    prevents a metadata update from a tablet server that no longer holds its
    lock.

* `srv:time []    M1373998392323` -
    This indicates the time time type (`M` for milliseconds or `L` for logical) and the timestamp of the most recently written key in this tablet.  It is used to ensure automatically assigned key timestamps are strictly increasing for the tablet, regardless of the tablet server's system time.

* `~tab:~pr []    \x00` -
    The end-row marker for the previous tablet (prev-row).  The first byte
    indicates the presence of a prev-row.  This tablet has the range (-inf, `inf),
    so it has no prev-row (or end row).

Besides these columns, you may see:

* `rowId future:zooKeeperID location` -
    Tablet has been assigned to a tablet, but not yet loaded.

* `~del:filename` -
    When a tablet server is done use a file, it will create a delete marker in the appropriate metadata table, unassociated with any tablet.  The garbage collector will remove the marker, and the file, when no other reference to the file exists.

* `~blip:txid` -
    Bulk-Load In Progress marker.

* `rowId loaded:filename` -
    A file has been bulk-loaded into this tablet, however the bulk load has not yet completed on other tablets, so this marker prevents the file from being loaded multiple times.

* `rowId !cloned` -
    A marker that indicates that this tablet has been successfully cloned.

* `rowId splitRatio:ratio` -
    A marker that indicates a split is in progress, and the files are being split at the given ratio.

* `rowId chopped` -
    A marker that indicates that the files in the tablet do not contain keys outside the range of the tablet.

* `rowId scan` -
    A marker that prevents a file from being removed while there are still active scans using it.

