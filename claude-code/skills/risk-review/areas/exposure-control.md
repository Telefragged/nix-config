# exposure-control

Can the change take effect for a subset of users or hosts first, and can it
be disabled without a revert?

## Not applicable when

The repository has no mechanism for staged delivery, and the change takes
effect only where its author applies it, as with personal configuration or a
local tool. Also when the change alters no behaviour.

## Check

- **Mechanism.** A feature flag, a configuration switch, a staged rollout, a
  canary, or enablement per host or per tenant. Does the repository have one,
  and does this change use it?
- **Off path.** With the switch off, is the behaviour identical to the
  behaviour before the change? Look for code outside the guard: refactors of
  the shared path, migrations that run regardless, dependency upgrades.
- **Default.** The default value of the switch, and which users or hosts get
  the change first.
- **Disable.** How long does disabling take? Does disabling undo the effects,
  or does data that the new path wrote remain?
- **Abort signal.** Which metric or check would trigger a disable? Does the
  first subset exercise the changed path at all?
- **Combinations.** Nested or interacting switches produce combinations that
  no test covers.

## Levels

- `low`: the behaviour change is behind a switch that defaults to off, and
  the off path is identical to the previous behaviour. Or an existing
  rollout mechanism applies the change to a subset first, with an abort
  signal.
- `medium`: a switch exists, but part of the change is outside it. Or the
  rollout is staged without an abort signal. Or disabling requires a deploy.
- `high`: the change takes effect for every user or host at once, and a
  revert is the only way to disable it.
