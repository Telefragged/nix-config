---
name: correct-by-construction
description: "Derive the states, transitions and invariants of a change from its business rules, then enforce each invariant at the highest level of the hierarchy of controls. Use to design or implement a feature, review a change, or fix a bug."
disable-model-invocation: true
---

# Correct by construction

Model the system as a state machine. Each business rule restricts which states
exist and which transitions are allowed between them. Each such restriction is
an invariant: a property that is true in every reachable state. Enforce every
invariant so that a violation cannot occur, or, failing that, stops the program
where it first occurs.

## Hierarchy of controls

From strongest to weakest:

1. **Eliminate.** The representation cannot contain the invalid state. Examples:
   - A sum type with one variant per state, each variant containing only the
     data that exists in that state, instead of a record of optional fields
     and flags.
   - One stored fact, with every other value derived from it, instead of two
     copies that can disagree.
   - A type per state that exposes only the transitions valid from that state.
   - Input checked once at the boundary and returned as a type that only the
     check can construct, instead of the same check repeated at each use.
2. **Assert.** The invalid state is representable, and an assert, enabled in
   debug and release builds, stops the program at the transition that
   produces it.
3. **Convention.** A comment, a name or a documented call order. Nothing
   enforces it.

Use the highest level the language and the surrounding code permit. Invalid
external input is not an invariant violation: return an error at the boundary,
and use level 1 for the value that passes.

Assert conditions have no side effects. Place each assert where the state is
produced, not only where it is consumed.

## Documentation

Document each invariant at its enforcement site, never in a separate file:

- Level 1: the doc comment on the type documents the invariant and the
  business rule it comes from.
- Level 2: the assert message documents the invariant and the business rule.

The invariants of a module are then the set of its type doc comments and
asserts.

## 1. Invariant list

Before any design, derive from the business rules of the task:

- **States**: each state, and the data that exists in it.
- **Transitions**: each allowed transition, its trigger and its precondition.
- **Invariants**: each invariant, and the business rule it comes from.
- **Open questions**: rules that are ambiguous or contradict each other, and
  reachable states for which no rule specifies behavior.

Include the states that business rules rarely cover: in flight, partially
failed, retried, concurrent, after a restart, and during a mixed-version
deploy. When the change modifies existing code, derive the current state
machine from the code first, and present the list as a diff against it.

Submit the list to the task's owner. Do not design until the owner approves it.

## 2. Design and implement

Sketch the types before writing code, and choose a level for each invariant.
These patterns indicate a missed level 1 design:

- A field that is valid only in some states.
- Boolean flags whose combinations are not all valid.
- The same fact stored in two places.
- A function that is valid only after another function has run.
- The same check repeated at several call sites.

Drive each level 2 invariant with a property test or fuzz target where an input
generator is feasible, so that the asserts run against generated states.

## 3. Review

Input: the approved invariant list and the change.

1. Before opening the list, derive the reachable states and transitions from
   the code, using the types rather than the comments.
2. **Coverage.** Report each invariant in the list that no type or assert
   enforces.
3. **Completeness.** Report each reachable state or transition from step 1
   that the list does not cover, and each invariant without a business rule.
4. **Level.** For each level 2 or 3 invariant, attempt a level 1 design that
   the surrounding code permits. Report it if one exists, with a sketch of
   the types.
5. **Placement.** Report each assert that sits where the state is consumed but
   not where it is produced.
6. **Exercise.** Report each assert that no test, property test or fuzz target
   reaches.
7. **Documentation.** Report each enforcement site whose doc comment or assert
   message omits the invariant or its business rule.

## 4. Fix a bug

1. Identify the invalid state or transition that produced the bug.
2. Find the invariant it violates. If the code contains no such invariant, the
   invariant list was incomplete: add the invariant and its business rule, and
   submit the addition to the owner as in step 1. If no business rule covers
   the case, report it as an open question.
3. Identify the level that enforced the invariant and why that level failed to
   stop the bug.
4. Fix at the highest level the code permits, so that the whole class of bug
   becomes impossible, not only this instance. A guard where the symptom
   appeared is a fix only when the state it handles is legitimate; see the
   **principle-fix-root-causes** skill.
5. Add a property test or fuzz target that generates the state.
