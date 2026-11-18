# testability

How much of the input space of the changed behaviour is verified, and can the
rest be verified at all?

## Not applicable when

The change alters no executable behaviour: documentation, comments or
formatting only.

## Check

- **Reach.** Which tests execute each changed branch? Find them by searching
  for the changed symbols or by running the suite. A test file with a
  matching file name is not evidence.
- **Kind.** Property-based tests, exhaustive enumeration, formal
  verification, model checking, or types that make the invalid cases
  unrepresentable. Below those: table-driven tests with boundary cases. Below
  those: one example per function.
- **Assertions.** Does each test assert the invariant that a later edit
  could break? For each test, find an incorrect edit to the changed code
  that the test would still pass. Tests without assertions, assertions on
  incidental details, snapshots regenerated in the same change, and mocks
  that replace the changed code verify nothing.
- **Unhappy paths.** Error paths, boundaries, empty and very large inputs,
  concurrent use.
- **Seams.** Can the changed code run in a test at all? Code that depends on
  the clock, the network, hardware or global data without a way to substitute
  them can only be verified in production.
- **Weakened tests.** Assertions deleted or loosened, or tests skipped, in
  the same change.
- **Flaky tests.** Tests added or edited by the change that depend on
  timing: polling, sleeps, short timeouts, unsynchronized threads or tasks.
  A test with controlled execution does not: it waits on a signal from the
  code under test, or runs under a deterministic scheduler or simulation
  (loom, DST, a paused clock).
- **Manual testing.** A commit message, PR description, attached output or
  documented procedure that records a manual test of the changed behaviour.
  It raises an untested branch from `high` to `medium` and no further.

## Levels

- `low`: every changed branch is covered by property-based, exhaustive or
  formally verified checks. Or the input space is small and the tests
  enumerate it.
- `medium`: example-based tests with assertions execute every changed branch,
  including error paths, but only sample the input space. Or a branch has no
  automated test and the change records a manual test of it. Or a test of the
  change depends on timing.
- `high`: at least one changed branch has no test that executes it and no
  recorded manual test. Or the tests execute the branch and an incorrect
  edit to it would still pass them. Or the changed code cannot run outside its production
  environment. Or the change weakens existing tests of the changed behaviour.
