---
name: risk-review
description: "Rate how risky each commit of a change is to merge, one level per risk area (revert, testability, complexity, blast radius and others), with one sub-agent per area. Use for 'risk review' or 'how risky is this change'. Accepts a commit or a commit range; defaults to the current branch's commits that its upstream lacks. A `.risk` file in the repository root selects the areas."
disable-model-invocation: true
---

# Risk review

Rate how risky each commit is to merge. One sub-agent per area returns
findings, each with a level. Do not fix anything, and do not open `reviewer.md` or
the area files yourself: the sub-agents open them.

## 1. List the commits

```sh
git rev-list --reverse <range>
```

The range is the argument: `A..B`, or `C^..C` for one commit. Without an
argument it is `@{upstream}..HEAD`, or `origin/HEAD..HEAD` when the branch has
no upstream. Stop if the list is empty.

## 2. Select the areas

The areas are the file names in `areas/` under this skill's base directory,
without `.md`. Without a `.risk` file in the repository root, enable all of
them.

In `.risk`, each `## <area>` heading enables that area, and the text under it
is that area's repo notes. Text before the first heading is notes for every
area. Report a heading that matches no area.

The bold label of each item of an area file's **Check** list is a category of
that area. Findings are counted by area and category over time, so do not
rename a label.

## 3. Spawn one sub-agent per area

Spawn them in one message. If a spawn is refused because of the limit on
concurrent sub-agents, spawn it again as the others return. Prompt:

```
Open <skill base>/reviewer.md and <skill base>/areas/<area>.md, and follow
both.

Repository: <repository root>
Commits, oldest first: <hashes>
Repo notes: <notes, or "none">
```

## 4. Check each section

Write the section that a sub-agent returns to a file, and run:

```sh
python3 <skill base>/findings.py -q --area <area> <file>
```

If it prints errors, resume that sub-agent with SendMessage:

```
findings.py reported these errors in your section:
<errors>
Give each finding the category of the Check item that it matches, and
correct the other errors. Drop a finding that matches no Check item. Return
the whole section again.
```

Check the new section. If it still has errors, resume the sub-agent once
more. After that, drop each finding that still has an error, and count it for
the report.

## 5. Report

When every section passes the check, open `report.md` in this skill's base
directory and follow it.
