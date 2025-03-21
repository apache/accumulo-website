---
title: Merging
category: administration
order: 6
---

Accumulo 4.0 has improved tablet merging support, including:

* Merging no longer requires "chop" compactions.
* Merging is now managed by FATE
* Accumulo now supports auto merging of tablets.

## New Merge Design

Merge used to be a slow operation because tablets had to be compacted before merging. This was necessary because Rfiles may contain data outside the tablet range and this data needed to be removed.
The updated merge algorithm works by "fencing" the RFiles in a tablet by the valid range. This operation is a fast metadata operation and the valid range of a file is now inserted into the file column. 
Scans will only return data in the specified range so compactions are no longer required. The normal system compaction process will eventually remove the data outside the range.

## Auto Merge 

Accumulo supports auto merging tablets that are below a certain threshold, similar to splitting tablets that are above a threshold.
The manager runs a task that periodically looks for ranges of tablets that can be merged. For a range of tablets to be eligible to be merged the following must be true:

1. All tablets in the range must be marked as eligible to be merged using the per tablet `TabletMergeability` setting. (more below)
2. The combined files must be less than `table.merge.file.max`
3. The total size must be less than `table.mergeability.threshold`. This is defined as the combined size of RFiles as a percentage of the split threshold

## Configuration

The following properties are used to configure merging:.

* `manager.tablet.mergeability.interval` -Time to wait between scanning tables to identify ranges of tablets that can be auto-merged (default is `24h`)
* `table.mergeability.threshold` - A range of tablets are eligible for automatic merging until the combined size of RFiles reaches this percentage of the split threshold. (default is `.25`)
* `table.merge.file.max` - The maximum number of files that a merge operation will process (default is `10000`)

## Tablet Mergeability

Each tablet can be marked individually with a value to indicate if/when it can be auto merged by the system.
The following are the possible settings:

* `NEVER` - Tablets are never eligible for automatic merging
* `ALWAYS` - Tablets are always eligible for automatic merging
* `DELAY` - Tablets are eligible to be merged after the configured delay, relative to the Manager time.

### Tablet Mergeability Defaults

* System generated splits - Defaults to `ALWAYS` mergeable. Any system created tablets are always eligible to be merged.
* User added splits - Defaults to `NEVER` mergeable if not specified.

### Configuring Tablets with the  API

#### Adding/updating splits

There is a new `putSplits()` method that takes a map of splits and mergeability settings and will either create those splits or update existing with the settings.

```java
// Adding splits or updating existing splits
String tableName = "table";
SortedMap<Text,TabletMergeability> splits = new TreeMap<>();
// Mark each split with its mergeability setting
splits.put(new Text(String.format("%09d", 333)), TabletMergeability.always());
splits.put(new Text(String.format("%09d", 444)), TabletMergeability.always());
splits.put(new Text(String.format("%09d", 666)), TabletMergeability.never());
splits.put(new Text(String.format("%09d", 999)),
  TabletMergeability.after(Duration.ofDays(1)));
// add or update splits
client.tableOperations().putSplits(String tableName, splits);
```

`TabletInformation` contains information describing the current mergeability state inside `TabletMergeAbilityInfo`.

#### Listing TabletMergeabilityInfo
```java
try (Stream<TabletInformation> tabletInfo =
        client.tableOperations().getTabletInformation(table, new Range())) {
        tabletInfo.forEach(ti -> {
    TabletMergeabilityInfo tmi = ti.getTabletMergeabilityInfo();
    // Some examples of the API usage
    // Gets the optional delay that is configured
    Optional<Duration> delay = tmi.getDelay();
    // If the tablet is currently eligilbe for merging
    boolean mergeable = tmi.isMergeable();
    // Optional estimated elapsed time since the delay was set
    Optional<Duration> elapsed = tmi.getElapsed();
    // Optional estimated remaining time before the tablet is eligible for merging
    Optional<Duration> remaining = tmi.getRemaining();
  });
}
```
