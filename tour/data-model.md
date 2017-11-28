---
title: Data Model
---
Data is stored in Accumulo in a distributed sorted map. The Keys of the map are broken up logically into a few different parts, 
as seen in the image below.

![key value pair]({{ site.url }}/images/docs/key_value.png)

**Row ID** - Unique identifier for the row.<br/>
**Column Family** - Logical grouping of the key. This field can be used to partition data within a node.<br/>
**Column Qualifier** - More specific attribute of the key.<br/>
**Column Visibility** - Security label controlling access to the key/value pair.<br/>
**Timestamp** - Generated automatically and used for versioning.

The **value** is where the actual data is stored. For brevity, we often refer to the 3 parts of the column as the family, qualifier and visibility. 

Take a closer look at the Mutation object created in the first exercise:
```java
Mutation mutation = new Mutation("id0001");
mutation.put("hero","alias", "Batman");
```
It can be broken down as follows: <br/>
**Row ID**: id0001  **Column Family**: hero  **Column Qualifier**: alias  **Value**: Batman

For this exercise add a few more rows to the GothamDB table.  Create a row for Robin (id0002), who is a hero that also wears a cape
and his name is "Dick Grayson".  Create a row for Joker (id0003), who is a villain with an "Unknown" name and doesn't wear a cape. Build and run.

Notice how the data is printed in sorted order. Accumulo sorts by Row ID then family and then qualifier.  