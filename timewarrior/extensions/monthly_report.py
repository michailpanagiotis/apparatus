#!/usr/bin/env python3
import re
import sys
from parser import parse_stdin
from zoneinfo import ZoneInfo

def __get_interval_hours(interval):
    return interval.seconds // 3600

def __get_interval_set_hours(iset):
    return iset.aggregate(__get_interval_hours, 0)

def __get_interval_set_month(iset):
    return iset.get_common_value(lambda i: i.format_start("%Y%m"))

config, interval_set = parse_stdin(sys.stdin, common_metadata={
    "hours": __get_interval_set_hours,
})

grouped = interval_set.group(
    predicate=lambda i: i.format_start("%B %Y"),
    common_metadata={
        "month": __get_interval_set_month,
        "hours": __get_interval_set_hours,
    },
    group_sort=lambda s: s.metadata.month
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

print("All for %s hours" % (interval_set.metadata.hours))
for per_month in grouped:
    print("  %s for %s hours" % (per_month.description, per_month.metadata.hours))
    for per_ticket in per_month.group(
        predicate=get_category,
        common_metadata={
            "hours": __get_interval_set_hours,
        },
    ):
        print("      %s for %s hours" % (per_ticket.description, per_ticket.metadata.hours))
        for interval in per_ticket:
            hours = __get_interval_hours(interval)
            print("        %s @%s for %s hours (%s)" % (
                interval.annotation,
                interval.format_start("%Y-%m-%d %H:%M", ZoneInfo('Europe/Athens')),
                hours,
                interval.id,
            ))
