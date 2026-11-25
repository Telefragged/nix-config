## Density

Mannered prose substitutes metaphor and flourish for direct statement.
Instead of "a parameter worth varying," the mannered writer produces "a dial
worth turning." Instead of "this point still matters," they write "this point
earns its keep." The phrases exist to display the writer, not to convey the
idea, and readers can tell. That is why mannered prose irritates: it makes
the reader work harder so the writer can perform. It is also imprecise.
Metaphors drag in connotations the writer did not choose and cannot control.
The fix is to say what you mean. When a literal phrase is available, use it.

Skip the preamble. If something might be unclear, let the user flag it instead of being defensive by adding 3 paragraphs when two sentences would've sufficed.

The user skips any response longer than two paragraphs, so a longer response communicates less, not more.

At the end of a turn, report only what the user cannot predict: a link to open, a failure, or a decision that only the user can make. Do not report a step that these instructions or the approve action define, such as auto-merge, the wait script or the cleanup. Do not repeat what the user did, such as an approval. When you open a pull request, report its URL and nothing else.

## No anthropomorphizing

Code, program, file, skill, prompt, rule, doc, commit, build, crate, value, flag or paths are not a person. Never give one of them a verb of speech, thought or intent. The reader then has to guess which technical act the verb stands for, and every guess costs attention. Use the exact software term:

| Do not write | Write the exact term |
| --- | --- |
| ask, ask for | request (HTTP), prompt (user input), require (a precondition), instruct (text that a model follows) |
| say, state, tell | document, print, return, contain, define |
| name | specify, contain, identify |
| read | parse, load, query, open |
| know, want, expect, decide, mean | require, accept, return, select |
| hold, carry | contain, store |
| call (X a violation) | match, report as |

A commit subject is an imperative, and its actor is the author of the change. So its verb is an edit: add, remove, rename, replace, fix, document, move. "plugin: say that X" and "plugin: ask for Y" break this rule. The subject also specifies the exact thing changed: "remove the second "canonical" in /nit:install", never "remove a repeated word".

No rhetorical openers or aphorisms, such as "Only a flag, never a path:". The rule covers code comments, doc-comments, commit messages, PR bodies, nit replies and chat. Fix such wording in any file you touch.

Write every commit message and nit reply to a file first, and check the file before you use it:

```sh
grep -nwiE 'asks?|asked|says?|said|tells?|told|names?|named|reads?|knows?|wants?|expects?|decides?|means?|holds?|carr(y|ies|ied)|calls?|called|stated?|states' <file>
```

For each hit, either the subject of the verb is a person, or you rewrite the sentence with a term from the table. Then commit with `git commit -F <file>`, or send with `nit comment -F <file>`.

## No history narration

When making code changes, leaving traces of review and change history in comments or documentation only leads to confusion when someone else reads the code later.

| Do not write | Write instead |
| --- | --- |
| "Documents belong to no repo", "No table stores the runs", "There is no JSON route", "X never refers to Y" | nothing; delete the sentence. State only what exists |
| now, no longer, previously, new, instead of, used to | the present state, with no reference to an earlier one |
| a sentence that explains a removed feature | nothing; remove its text and add none in its place |
| "The reviewer edits a document", "A change has revisions", "An agent cannot use X" | the plural: "Reviewers edit documents", "Changes have revisions", "Agents cannot use X" |
| a commit body that describes the code, the design or the tests | one short paragraph of motivation: what was wrong or missing for the people who use it; an empty body when there is none |
| a commit subject with a coined verb: deliver, surface, power, introduce | an imperative edit with the identifier or the file: add, remove, rename, replace, move, post |
| a label that repeats what the state of a control shows ("The author has this version" beside a disabled Send button) | nothing; delete the label |
| a paragraph, a section or a list item that the task did not request | nothing |
