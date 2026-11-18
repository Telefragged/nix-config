# novelty

Does the change follow a pattern that this repository has used before, or is
it the first of its kind here?

## Not applicable when

Never.

## Check

- **New components.** A new dependency, language, framework, tool, service,
  storage system or protocol.
- **Second pattern.** A new approach to a problem for which the repository
  already has one, such as a second HTTP client or a second error-handling
  style.
- **First use of a hazardous facility.** Concurrency, `unsafe`, raw SQL,
  shell commands, cryptography, custom serialization.
- **Precedent.** Find earlier commits of the same shape with `git log` on
  the same files or the same pattern. Did they require follow-up fixes or
  reverts?
- **Dependency maturity.** For a new dependency: its version, its
  maintenance activity, and whether the version is pinned.
- **History of the touched code.** Code that has not changed for a long
  time, or code whose history contains repeated fixes and reverts.

## Levels

- `low`: the change has the same shape as earlier changes in the repository,
  and those required no follow-up fix.
- `medium`: the change uses an existing dependency or pattern in a new
  place. Or it deviates from the repository's existing pattern for the same
  problem. Or it edits code whose history contains repeated fixes or
  reverts.
- `high`: the change is the first use in the repository of a dependency,
  service, protocol, storage system or hazardous facility, and no earlier
  change provides a comparison.
