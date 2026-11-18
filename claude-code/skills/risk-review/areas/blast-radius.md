# blast-radius

If the change is wrong, how much stops working, and for whom?

Rate the extent of a failure. Its likelihood belongs to the other areas.

## Not applicable when

Never.

## Check

- **Dependents.** Search for the callers and importers of every changed
  symbol, file and configuration key. Is the changed code a leaf, or is it
  shared: a utility, a base class, middleware, a schema, build or CI
  configuration?
- **Frequency.** Does the changed code run on every request, every start or
  every build, or only on a rare path?
- **Audience.** Every user, host and environment, or one feature, one host,
  one tenant?
- **Containment.** Does a failure in the changed code stop the process, the
  start-up or the build? Or does a handler isolate it, as for an optional
  feature?
- **Worst outcome.** An unavailable feature, lost or corrupted data, or a
  security or financial effect.
- **Recovery path.** Does the change touch what recovery depends on:
  authentication, deployment, boot, login, shell initialization, backups?

## Levels

- `low`: a failure is limited to the feature under change. Few dependents. No
  data that other features use is written.
- `medium`: a failure affects several features or a shared code path. The
  system stays usable, or a restart or a revert recovers it.
- `high`: a failure affects every user or host, or the start-up, login,
  build or deployment path. Or it can lose or corrupt data. Or it disables
  the means of recovery.
