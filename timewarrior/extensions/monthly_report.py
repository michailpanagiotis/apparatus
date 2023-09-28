#!/usr/bin/env python3
import re
import sys
from parser import parse_stdin

config, intervals = parse_stdin(sys.stdin)

grouped = intervals.group(
    predicate=lambda i: i.format_start("%Y%m"),
    description_fn=lambda i: i.format_start("%B %Y"),
)
def get_category(interval):
    ticket = None
    for tag in interval.tags:
        match = re.match("(SDK(?:-\d+)?\.SDK-\d+)", tag)
        if match:
            ticket = match.group(1)
            continue
    if ticket:
        return "Ticket: %s" %ticket
    if 'Meeting' in interval.tags:
        return 'Meetings'
    if 'Candidate assessment' in interval.tags:
        return 'Candidate assessment'
    if 'Deployment' in interval.tags:
        return 'Deployment'
    raise Exception('unknown category for %s' % interval.id)

print(intervals)
for per_month in grouped:
    print("  %s" % str(per_month))
    for per_ticket in per_month.group(
        predicate=get_category,
        description_fn=get_category,
    ):
        print("    %s" % str(per_ticket))
        for interval in per_ticket.to_list():
            print("        %s %s @%s for %s hours" % (interval.id, interval.annotation, interval.format_start("%H:%M"), interval.get_hours()))
