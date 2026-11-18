# mixed-version

While the previous and the new version of the code run at the same time, or
exchange data, does each version handle what the other produces?

This differs from `revert`: the two versions coexist during a normal rollout,
without any failure.

## Not applicable when

One instance of the program runs, it is replaced in one step, and no stored
data and no external client crosses the version boundary. The repo notes from
`.risk` normally settle this.

## Check

- **Boundaries.** Where do the versions meet? Instances in a rolling deploy.
  Client and server, including old installed clients and cached scripts.
  Queued jobs that one version enqueues and the other consumes. A shared
  database schema. Caches, files, RPC and API schemas, configuration.
- **Both directions.** For each boundary: new code with old data, and old
  code with new data.
- **Shape changes.** Fields added, removed, renamed or retyped. New enum
  values. Required versus optional. Handling of unknown fields.
- **Order.** Does the change require a deployment order, such as migration
  before code, or server before client? Is that order documented or
  enforced?
- **Expand and contract.** Does the change add the new form and remove the
  old form in the same step?

## Levels

- `low`: both directions are compatible at every boundary. Or the change
  only adds optional data that the previous code ignores.
- `medium`: the versions are compatible only in a deployment order that is
  documented or enforced. Or the mismatch causes errors that retries clear
  once the rollout completes.
- `high`: at some boundary, the previous code fails on or misinterprets new
  data, or the new code fails on old data. Or the change adds the new form
  and removes the old form in one step. Or a required deployment order is
  undocumented.
