---
title: Accumulo Shell
category: getting-started
order: 5
---

Accumulo provides a simple shell that can be used to examine the contents and
configuration settings of tables, insert/update/delete values, and change
configuration settings.

The shell can be started by the following command:

    accumulo shell -u [username]

The shell will prompt for the corresponding password to the username specified
and then display the following prompt:

    Shell - Apache Accumulo Interactive Shell
    -
    - version: {{ page.latest_release }}
    - instance name: myinstance
    - instance id: 00000000-0000-0000-0000-000000000000
    -
    - type 'help' for a list of available commands
    -
    root@myinstance>

## Basic Administration

The `tables` command will list all existing tables.

    root@myinstance> tables
    accumulo.metadata
    accumulo.root

The `createtable` command creates a new table.

    root@myinstance> createtable mytable
    root@myinstance mytable> tables
    accumulo.metadata
    accumulo.root
    mytable

The `deletetable` command deletes a table.

    root@myinstance testtable> deletetable testtable
    deletetable { testtable } (yes|no)? yes
    Table: [testtable] has been deleted.

The shell can be used to insert updates and scan tables. This is useful for inspecting tables.

    root@myinstance mytable> scan

    root@myinstance mytable> insert row1 colf colq value1
    insert successful

    root@myinstance mytable> scan
    row1 colf:colq [] value1

The value in brackets `[]` would be the visibility labels. Since none were used, this is empty for this row.
You can use the `-st` option to scan to see the timestamp for the cell, too.

## Table Maintenance

The `compact` command instructs Accumulo to schedule a compaction of the table during which
files are consolidated and deleted entries are removed.

    root@myinstance mytable> compact -t mytable
    07 16:13:53,201 [shell.Shell] INFO : Compaction of table mytable started for given range

If needed, the compaction can be canceled using `compact --cancel -t mytable`.

The `flush` command instructs Accumulo to write all entries currently in memory for a given table
to disk.

    root@myinstance mytable> flush -t mytable
    07 16:14:19,351 [shell.Shell] INFO : Flush of table mytable
    initiated...

## User Administration

The Shell can be used to add, remove, and grant privileges to users.

```
root@myinstance mytable> createuser bob
Enter new password for 'bob': *********
Please confirm new password for 'bob': *********

root@myinstance mytable> authenticate bob
Enter current password for 'bob': *********
Valid

root@myinstance mytable> grant System.CREATE_TABLE -s -u bob

root@myinstance mytable> user bob
Enter current password for 'bob': *********

bob@myinstance mytable> userpermissions
System permissions: System.CREATE_TABLE
Table permissions (accumulo.metadata): Table.READ
Table permissions (mytable): NONE

bob@myinstance mytable> createtable bobstable

bob@myinstance bobstable>

bob@myinstance bobstable> user root
Enter current password for 'root': *********

root@myinstance bobstable> revoke System.CREATE_TABLE -s -u bob
```
