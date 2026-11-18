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

## 4. Report

When every sub-agent has returned, open `report.md` in this skill's base
directory and follow it.
