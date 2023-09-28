#!/usr/bin/env python3
import sys
import re

from parser import parse_stdin

config, intervals = parse_stdin(sys.stdin)

for interval in intervals.values():
    is_adhoc = False
    jira_ticket = None
    for tag in interval.tags:
        if tag == "Meeting":
            is_adhoc = True
            continue
        if tag == "Deployment":
            is_adhoc = True
            continue
        if tag == "Candidate assessment":
            is_adhoc = True
            continue
        if tag == "Bespot":
            continue
        match = re.match("(SDK(?:-\d+)?\.SDK-\d+)", tag)
        if match:
            jira_ticket = match.group(1)
            continue
        print('@%s has unknown tag %s' % (interval.id, tag))

    if is_adhoc:
        continue

    if jira_ticket:
        continue

    print('@%s %s has no ticket' % (
        interval.id,
        ", ".join(interval.tags),
    ))
