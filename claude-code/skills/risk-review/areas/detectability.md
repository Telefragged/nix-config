# detectability

If the change is wrong, what detects the failure, and how soon?

## Not applicable when

The change alters no executable behaviour and no configuration:
documentation, comments or formatting only.

## Check

- **Failure mode.** Loud: a crash, an exception, a failed build, a type
  error. Silent: a wrong value, a dropped record, skipped work, a stale
  cache entry.
- **Discarded errors.** Catch-all handlers, ignored return values, `|| true`,
  fallback to a default value, errors logged only at debug level.
- **Signals.** Does a metric, log line, alert, health check or CI job cover
  the changed path? Does the change add or remove one?
- **Delay.** Is a failure visible at build or start-up, or only at a rare
  event: a monthly job, a certificate renewal, a backup restore, an error
  path?
- **Detector.** An automated check, a user report, or nothing.
- **Accumulation.** Does damage grow before detection, as with repeated bad
  writes?

## Levels

- `low`: a failure appears at build, at start-up or on first use, with an
  error that identifies the cause.
- `medium`: a failure is visible, but only on a rarely executed path or
  through a user report. Or the error does not identify the cause.
- `high`: a failure produces wrong results or wrong data without an error.
  Or the changed code discards its errors. Or the failure appears only after
  damage has accumulated. In each case, no existing check covers the path.
