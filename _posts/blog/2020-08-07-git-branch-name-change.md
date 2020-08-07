---
title: GitHub Branch Renaming
author: Christopher Tubbs
---

# Overview
The Accumulo Apache Community voted to rename the master branches in our GitHub repositories.  
The main repository [Accumulo][Accumulo] has been changed and the change will roll out to the
sub-projects shortly.

# What You Can Do to Help
Update your local clones and your forks, so that the 'master' branch is fully gone.

### Removing master from local clones: 
Assuming upstream is the name of your upstream remote;
`git remote update --prune && git checkout -t upstream/main && git branch -d master`
After the default branch is changed by INFRA, you can also do the following if you wish:
`git remote set-head upstream -a`

### Removing master from forked copies:
tbd.

- [Accumulo](https://github.com/apache/accumulo)
