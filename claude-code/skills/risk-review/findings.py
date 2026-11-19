"""Parse and validate risk-review findings.

  findings.py [--area <area>] [-q] <file>

Parse each finding in the file, such as a report, a section or one finding,
and print the findings as a JSON list. With --area, the file is the section of
that area, as reviewer.md defines it. With -q, print no JSON. Print each error
to stderr, and exit 1 if there is one.

A finding is:

  [<area>:<category>] <one sentence>

  <description: one or more paragraphs>

  Level: <high | unknown | medium>
  Commit: <abbreviated hash>
  Location: <path>:<line>

The category is the bold label of an item of the Check list of areas/<area>.md,
in lower case with hyphens for spaces.
"""

import argparse
import json
import re
import sys
from pathlib import Path

AREAS = Path(__file__).resolve().parent / "areas"
FINDING_LEVELS = ["high", "unknown", "medium"]
SECTION_LEVELS = FINDING_LEVELS + ["low", "n/a"]

HEADING = re.compile(r"## (?P<area>[a-z0-9-]+): (?P<level>\S+)")
SUBJECT_START = re.compile(r"\[[^\]\s]*\] ")
SUBJECT = re.compile(r"\[(?P<area>[a-z0-9-]+):(?P<category>[a-z0-9-]+)\] (?P<text>\S.*)")
TRAILER = re.compile(r"(?P<key>[A-Za-z-]+): (?P<value>\S.*)")
TRAILER_VALUES = {
    "Level": re.compile("|".join(FINDING_LEVELS)),
    "Commit": re.compile(r"[0-9a-f]{7,40}"),
    "Location": re.compile(r"(?P<path>\S.*):(?P<line>[1-9][0-9]*)"),
}


def categories(area):
    """Return the bold labels of the Check list of an area file, in lower case with hyphens for spaces."""
    path = AREAS / f"{area}.md"
    if not path.is_file():
        return None
    check = re.search(r"^## Check\n(.*?)(?=^## |\Z)", path.read_text(), re.M | re.S)
    labels = re.findall(r"^- \*\*([^*]+?)\.\*\*", check.group(1), re.M)
    return {re.sub(r"[^a-z0-9]+", "-", label.lower()) for label in labels}


def paragraph(lines, i):
    """Return the paragraph that starts at the first non-blank line from i, and the index after it."""
    while i < len(lines) and not lines[i][1].strip():
        i += 1
    start = i
    while i < len(lines) and lines[i][1].strip():
        i += 1
    return lines[start:i], i


def parse_finding(lines, i):
    """Parse the finding whose subject is lines[i]. Return (finding or None, errors, index after it)."""
    number, line = lines[i]
    errors = []
    subject = SUBJECT.fullmatch(line)
    if not subject:
        errors.append(f"line {number}: not a '[<area>:<category>] <one sentence>' subject: {line}")
    else:
        known = categories(subject["area"])
        if known is None:
            errors.append(f"line {number}: no area file {subject['area']}.md")
        elif subject["category"] not in known:
            errors.append(
                f"line {number}: category '{subject['category']}' is not in the Check list of "
                f"{subject['area']}: {', '.join(sorted(known))}"
            )
    if i + 1 < len(lines) and lines[i + 1][1].strip():
        errors.append(f"line {lines[i + 1][0]}: the subject must be followed by an empty line")

    description = []
    trailers = None
    j = i + 1
    while True:
        para, after = paragraph(lines, j)
        if not para:
            errors.append(f"line {number}: the finding has no trailers")
            break
        if SUBJECT_START.match(para[0][1]):
            errors.append(f"line {number}: the finding has no trailers")
            break
        j = after
        first = TRAILER.fullmatch(para[0][1])
        if first and first["key"] in TRAILER_VALUES:
            trailers = para
            break
        description.append("\n".join(text for _, text in para))
    if not description:
        errors.append(f"line {number}: the finding has no description")

    values, seen = {}, set()
    for trailer_number, text in trailers or []:
        trailer = TRAILER.fullmatch(text)
        if not trailer:
            errors.append(f"line {trailer_number}: not a 'Key: value' trailer: {text}")
            continue
        key, value = trailer["key"], trailer["value"]
        if key in seen:
            errors.append(f"line {trailer_number}: repeated trailer {key}")
            continue
        seen.add(key)
        if key not in TRAILER_VALUES:
            errors.append(f"line {trailer_number}: unknown trailer {key}; the trailers are {', '.join(TRAILER_VALUES)}")
        elif not TRAILER_VALUES[key].fullmatch(value):
            errors.append(f"line {trailer_number}: invalid {key}: {value}")
        else:
            values[key] = value
    if trailers is not None:
        for key in TRAILER_VALUES:
            if key not in seen:
                errors.append(f"line {number}: missing trailer {key}")

    if errors:
        return None, errors, j
    location = TRAILER_VALUES["Location"].fullmatch(values["Location"])
    return {
        "area": subject["area"],
        "category": subject["category"],
        "finding": subject["text"],
        "description": "\n\n".join(description),
        "level": values["Level"],
        "commit": values["Commit"],
        "path": location["path"],
        "line": int(location["line"]),
        "text": "\n".join(text for _, text in lines[i:j]),
    }, [], j


def parse(text):
    """Return (findings, errors, the numbered non-blank lines outside findings)."""
    lines = list(enumerate(text.splitlines(), start=1))
    findings, errors, other = [], [], []
    i = 0
    while i < len(lines):
        if SUBJECT_START.match(lines[i][1]):
            finding, finding_errors, i = parse_finding(lines, i)
            errors += finding_errors
            if finding:
                findings.append(finding)
        else:
            if lines[i][1].strip():
                other.append(lines[i])
            i += 1
    return findings, errors, other


def check_section(area, findings, other):
    """Return the errors of a section of one area, given the output of parse."""
    if categories(area) is None:
        return [f"no area file {area}.md"]
    if not other:
        return [f"no '## {area}: <level>' heading"]
    number, line = other[0]
    heading = HEADING.fullmatch(line)
    if not heading:
        return [f"line {number}: not a '## <area>: <level>' heading: {line}"]
    errors = []
    if heading["area"] != area:
        errors.append(f"line {number}: area {heading['area']} is not {area}")
    if heading["level"] not in SECTION_LEVELS:
        errors.append(f"line {number}: level {heading['level']} is not one of {', '.join(SECTION_LEVELS)}")
    for extra_number, extra in other[1:]:
        errors.append(f"line {extra_number}: text outside a finding: {extra}")
    for finding in findings:
        if finding["area"] != area:
            errors.append(f"finding '{finding['finding']}': area {finding['area']} is not {area}")

    levels = [finding["level"] for finding in findings]
    if levels:
        highest = min(levels, key=FINDING_LEVELS.index)
        if heading["level"] != highest:
            errors.append(f"line {number}: level {heading['level']} is not the highest finding level, {highest}")
    elif heading["level"] in FINDING_LEVELS:
        errors.append(f"line {number}: level {heading['level']} without findings")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--area", help="validate the file as the section of this area")
    parser.add_argument("-q", "--quiet", action="store_true", help="print no JSON")
    parser.add_argument("file", type=Path)
    args = parser.parse_args()

    findings, errors, other = parse(args.file.read_text())
    if args.area:
        errors += check_section(args.area, findings, other)
    for error in errors:
        print(error, file=sys.stderr)
    if not args.quiet:
        print(json.dumps(findings, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
