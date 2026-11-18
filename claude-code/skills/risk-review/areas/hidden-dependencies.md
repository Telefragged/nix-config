# hidden-dependencies

Does anything outside the diff depend on behaviour that the change alters,
through a link that the compiler, the tests and a symbol search do not find?

## Not applicable when

Never. A change that alters no behaviour and no identifier is `low`.

## Check

- **Implicit contracts.** Output that other programs parse: log lines, CLI
  output, file paths, JSON shape. Ordering, timing, exit codes, error
  messages matched as strings, environment variables, ports.
- **Consumers outside the code.** Other repositories and services, scripts,
  dashboards and alerts that query a metric or log line, cron jobs, CI
  configuration, runbooks, infrastructure configuration.
- **Dynamic references.** Reflection, identifiers built from strings,
  dispatch driven by configuration, SQL in strings, templates.
- **Duplicated logic.** The same constant or rule in two places that must
  stay equal: client and server validation, a schema and its types.
- **Transitive effects.** A dependency upgrade that alters behaviour for
  other callers. An edit to a shared default or global.
- **Removed or renamed identifiers.** Search the whole repository for the
  old identifier as a string, including files that are not code.

## Levels

- `low`: every altered behaviour is referenced only through symbols that the
  compiler or the tests check, and a string search for the altered
  identifiers finds no other reference.
- `medium`: an implicit consumer exists in the repository and the change
  updates it, but nothing enforces that the two stay equal. Or the altered
  behaviour is published surface and the change is additive.
- `high`: a consumer of the altered output, format, identifier or timing
  exists and the change does not update it. Or the change alters published
  surface incompatibly: an API, CLI output, metric identifiers.

If consumers outside the repository are possible and cannot be checked from
here, the level is `unknown`.
