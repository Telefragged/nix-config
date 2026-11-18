# revert

After the change has run in its target environment, does `git revert` restore
the previous behaviour, with nothing left behind that the previous code
cannot handle?

## Not applicable when

Never. A change with no runtime effect is `low`.

## Check

- **Mechanics.** Does the change span several commits that must be reverted
  together or in a fixed order? Does it edit lines that other recent commits
  also edit, so that `git revert` would conflict?
- **Persistent data.** Migrations, schema changes, new file or serialization
  formats, cache keys, files written to disk. After the new code has run, can
  the previous code parse what it wrote?
- **Down path.** Does each migration have a down migration? Does the down
  migration lose data?
- **New surface.** API endpoints, CLI flags, configuration keys and exported
  functions that a consumer can start to depend on. A revert removes them.
- **Changed behaviour.** Defaults, output formats and error codes that
  consumers adapt to. A revert changes them a second time.
- **One-way effects.** Deleted data, sent messages, created or renamed
  external resources.
- **Dependencies.** Upgrades that rewrite a lock file or an on-disk format
  that the previous version cannot load.

## Levels

- `low`: a revert restores the previous behaviour completely. The change
  writes no persistent data in a new format and adds no surface that code
  outside the repository can use.
- `medium`: a revert works after one known manual step, such as a down
  migration or a cache clear. Or the revert removes surface that a consumer
  may have adopted. Or several commits must be reverted together.
- `high`: once the new code has run, the previous code cannot handle the
  data. Or a migration has no down path or a lossy one. Or the change has an
  external effect that cannot be undone. Or the change deletes data.
