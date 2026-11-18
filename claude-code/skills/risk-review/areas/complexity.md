# complexity

Can a reviewer who is competent in the language and the domain, and who did
not write the change, determine what it does and why from the change and the
code it touches?

Complexity that the problem requires, such as a parser or a concurrent data
structure, is not a finding by itself. In that case, rate whether the change
documents its invariants and tests them. The target is not the simplest
possible code for the least experienced reader.

## Not applicable when

Never.

## Check

- **Summary.** Write two sentences on what the change does. Compare them with
  the commit message or PR description. A mismatch is evidence.
- **Undetermined lines.** List every line whose purpose you could not
  determine. Each one is direct evidence.
- **Indirection.** The number of files and layers to trace for one behaviour.
  Metaprogramming, macros, reflection, generated code, dispatch through
  strings.
- **Implicit invariants.** Invariants that no type or assertion enforces.
  Dependence on evaluation order. Effects at a distance through globals,
  environment variables or monkey patching.
- **Simpler equivalent.** Bit manipulation, dense one-line expressions and
  hand-written algorithms where the standard library or an existing
  dependency provides the same behaviour.
- **Hazardous constructs.** Concurrency, `unsafe`, manual memory management,
  lifetimes, retries and timeouts.
- **Structure.** Misleading identifiers. A function that does two unrelated
  things.

## Levels

- `low`: the behaviour follows from one linear pass over the diff. Types or
  assertions enforce every invariant that the change depends on.
- `medium`: determining the behaviour requires tracing code outside the diff.
  Or an invariant is documented only in a comment. Or a simpler equivalent
  exists for a minor part of the change.
- `high`: you cannot determine what part of the change does. Or correctness
  depends on an undocumented invariant, ordering or timing. Or a much simpler
  implementation with the same behaviour exists for the main part of the
  change.
