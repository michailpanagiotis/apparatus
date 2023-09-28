#!/usr/bin/env python3
import re
import sys
from parser import parse_stdin
from functools import cmp_to_key
from zoneinfo import ZoneInfo

zoneinfo = ZoneInfo('Europe/Athens')

def __get_interval_hours(interval):
    return interval.seconds // 3600

def __get_interval_category(interval):
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
    if 'Deployment' in interval.tags:
        return 'Deployment'
    if 'Candidate assessment' in interval.tags:
        return 'Candidate assessment'
    raise Exception('unknown category for %s' % interval.id)

def __compare_within_month(iset1, iset2):
    if iset1.description == 'Meetings':
        return 1
    if iset1.description == 'Deployment':
        return 1
    if iset1.description == 'Candidate assessment':
        return 1
    if iset2.description == 'Meetings':
        return -1
    if iset2.description == 'Deployment':
        return -1
    if iset2.description == 'Candidate assessment':
        return -1
    if iset1.start < iset2.start:
        return -1
    return 1

def __get_interval_set_hours(iset):
    return iset.aggregate(__get_interval_hours, 0)

def __get_minimum_start(iset):
    return iset.min(lambda i: i.period[0]).astimezone(zoneinfo)

def __get_interval_set_month(iset):
    return iset.get_common_value(lambda i: i.format_start("%Y%m"))

config, interval_set = parse_stdin(sys.stdin, annotate={
    "hours": __get_interval_set_hours,
})

print("All for %s hours" % (interval_set.hours))
for monthly_set in interval_set.group(
    predicate=lambda i: i.format_start("%B %Y"),
    annotate={
        "month": __get_interval_set_month,
        "hours": __get_interval_set_hours,
        "start": __get_minimum_start,
    },
    group_sort=lambda s: s.month
):
    print("    %s for %s hours" % (monthly_set.description, monthly_set.hours))
    for ticket_set in monthly_set.group(
        predicate=__get_interval_category,
        annotate={
            "hours": __get_interval_set_hours,
            "start": __get_minimum_start,
        },
        group_sort=cmp_to_key(__compare_within_month),
    ):
        print("        %s @%s for %s hours" % (ticket_set.description, ticket_set.start, ticket_set.hours))
        for interval in ticket_set:
            hours = __get_interval_hours(interval)
            print("            %s @%s for %s hours (#%s)" % (
                interval.annotation,
                interval.format_start("%Y-%m-%d %H:%M", zoneinfo),
                hours,
                interval.id,
            ))
