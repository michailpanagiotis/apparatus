#!/usr/bin/env python3
import json
import re
import sys
from parser import parse_stdin
from functools import cmp_to_key
from zoneinfo import ZoneInfo

zoneinfo = ZoneInfo('Europe/Athens')

def date_fmt(date, format = '%Y%m%d %H:%M'):
    return date.astimezone(zoneinfo).strftime(format)

def format_start(format = '%Y%m%d %H:%M'):
    return lambda i: date_fmt(i.start, format)

def __get_interval_category(interval):
    ticket = None
    for tag in interval.tags:
        match = re.match("(([A-Z]+(-[0-9]+)?)\.)?(?P<ticket>[A-Z]+-[0-9]+)", tag)
        if match:
            ticket = match.group("ticket")
            continue
    if ticket:
        return "Ticket: %s" %ticket
    if 'Meeting' in interval.tags:
        return 'Meetings'
    if 'Deployment' in interval.tags:
        return 'Deployment'
    if 'Release' in interval.tags:
        return 'Release'
    if 'Candidate assessment' in interval.tags:
        return 'Candidate assessment'
    if 'Research' in interval.tags:
        return 'Research'
    if 'Incident' in interval.tags:
        return 'Incident'
    raise Exception('unknown category for @%s' % interval.id)

def __compare_isets(iset1, iset2):
    if iset1.month < iset2.month:
        return -1
    if iset1.month > iset2.month:
        return 1
    if iset1.category == 'Meetings':
        return 1
    if iset1.category == 'Deployment':
        return 1
    if iset1.category == 'Candidate assessment':
        return 1
    if iset2.category == 'Meetings':
        return -1
    if iset2.category == 'Deployment':
        return -1
    if iset2.category == 'Candidate assessment':
        return -1
    if iset1.start < iset2.start:
        return -1
    return 1

def __get_minimum_start(iset):
    return iset.min(lambda i: i.start).astimezone(zoneinfo)

def __get_interval_set_month(iset):
    return iset.get_common_value(format_start("%Y%m"))

def __get_interval_set_category(iset):
    return iset.get_common_value(__get_interval_category)

def get_group_value(fn):
    return lambda iset: iset.get_common_value(fn)

config, interval_set = parse_stdin(sys.stdin)

per_month = interval_set.group(
    predicate=format_start("%B %Y"),
    annotate={
        "month": __get_interval_set_month,
    },
    sort=lambda s: s.month
)

print("Tree summary, total hours: %s" % (interval_set.total_hours))
for monthly_set in per_month:
    print("    %s for %s hours" % (monthly_set.description, monthly_set.total_hours))
    per_ticket = monthly_set.group(
        predicate=__get_interval_category,
        annotate={
            "category": get_group_value(__get_interval_category),
            "month": get_group_value(format_start("%Y%m")),
        },
        sort=cmp_to_key(__compare_isets)
    )
    for ticket_set in per_ticket:
        print("        %s @%s for %s hours" % (ticket_set.description, ticket_set.start, ticket_set.total_hours))
        for interval in ticket_set:
            print("            %s @%s for %s hours (#%s)" % (
                interval.annotation,
                format_start("%Y-%m-%d %H:%M")(interval),
                interval.total_hours,
                interval.id,
            ))


print("\nSummary CSV")
csv_group = interval_set.group(
    predicate=lambda i: "%s %s" % (format_start("%B %Y")(i), __get_interval_category(i)),
    annotate={
        "category": get_group_value(__get_interval_category),
        "year": get_group_value(format_start("%Y")),
        "month": get_group_value(format_start("%B")),
    },
    sort=cmp_to_key(__compare_isets)
).csv(sys.stdout, ['year', 'month', 'total_hours', 'category'])


print("\nDetailed CSV")
csv_group = interval_set.group(
    predicate=lambda i: i.id,
    annotate={
        "category": get_group_value(__get_interval_category),
        "description": get_group_value(lambda i: i.annotation),
        "datetime": get_group_value(format_start()),
    },
    sort=__get_minimum_start,
).csv(sys.stdout, ['datetime', 'total_hours', 'category', 'description'])
