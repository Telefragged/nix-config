# Risk report

Each sub-agent returns a Markdown section: a `## <area>: <level>` heading,
followed by its findings unless the level is `low` or `n/a`. Print:

```markdown
Overall: <the highest level; `unknown` counts as `high`>

| area | level | findings |
| --- | --- | --- |
| <area> | <level> | <count> |

low: <areas>
n/a: <areas>

<the sections with findings, unchanged, sorted by area>
```

The table has one row per area with findings, sorted by area identifier.
Omit the table or a line that has no entries.

A sub-agent that failed gets a table row at `unknown` with no count.

Before you print the report, write it to a file and run
`python3 <skill base>/findings.py -q <file>`. It must print no errors.

If step 4 dropped findings, add a line after the `n/a` line:
`dropped: <area> <count>, ...`.
