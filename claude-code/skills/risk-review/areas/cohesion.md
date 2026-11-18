# cohesion

Does the change have one purpose, so that it can be reviewed, reverted and
bisected as a unit?

## Not applicable when

Never.

## Check

- **Purposes.** List the distinct purposes in the diff: feature, bug fix,
  refactor, rename, formatting, dependency upgrade, generated files.
- **Refactor with behaviour change.** A commit that moves code and modifies
  it prevents the reviewer from separating the moved lines from the modified
  lines.
- **Mechanical diffs.** Mass formatting or renaming that contains functional
  hunks.
- **Unrelated files.** Files that the stated purpose does not require.
- **Commit structure.** Does each commit build and pass the tests without
  the later commits?
- **Partial revert.** Can one purpose be reverted without the others?
- **Size.** Size relative to the purpose, excluding generated files and lock
  files.

## Levels

- `low`: one purpose. Or several commits, each with one purpose.
- `medium`: the change includes a second purpose that is small and
  separable, such as an unrelated one-line fix or a rename. Or mechanical
  edits are mixed in and remain identifiable.
- `high`: one commit changes behaviour for unrelated purposes. Or functional
  hunks are inside a large mechanical diff. Or reverting one purpose requires
  manual editing.
