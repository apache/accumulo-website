---
title: Data Model
---

Data is stored in Accumulo in a distributed sorted map. The `Key's` of the map are broken up logically 
into a few different parts, as seen in the image below.

![key value pair]({{ site.baseurl }}/images/docs/key_value.png)

<br/>

| **Row ID** | Unique identifier for the row |
| **Column Family** | Logical grouping of the key. This field can be used to partition data within a node |
| **Column Qualifier** | More specific attribute of the key |
| **Column Visibility** | Security label controlling access to the key/value pair |
| **Timestamp** | Generated automatically and used for versioning |

The **value** is where the actual data is stored. For brevity, we often refer to the 3 parts of the 
column as the family, qualifier, and visibility.

Take a closer look at the Mutation object created in the first exercise:
```commandline
Mutation mutation1 = new Mutation("id0001");
mutation1.put("hero","alias", "Batman");
```
It can be broken down as follows: <br/>

| **Row ID**: | id0001 |
| **Column Family**: | hero |  
| **Column Qualifier**: | alias |
| **Value**: | Batman |

As an exercise, add a few more rows to the GothamPD table.  Create a row for Robin (id0002), who is a 
hero that also wears a cape and his name is "Dick Grayson".  Create a row for Joker (id0003), who is 
a villain with an "Unknown" name and doesn't wear a cape. Compare your output to the output displayed 
on the next page.

Notice how the data is printed in sorted order. Accumulo sorts by Row ID, then Family, and then 
Qualifier.
