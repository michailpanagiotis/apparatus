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

def __get_interval_set_hours(iset):
    return iset.aggregate(__get_interval_hours, 0)

def __get_minimum_start(iset):
    return iset.min(lambda i: i.period[0]).astimezone(zoneinfo)

def __get_interval_set_month(iset):
    return iset.get_common_value(lambda i: i.format_start("%Y%m"))

def __get_interval_set_category(iset):
    return iset.get_common_value(__get_interval_category)

def get_common_interval_value(fn):
    return lambda iset: iset.get_common_value(fn)

# annotate={
#     "month": __get_interval_set_month,
#     "hours": __get_interval_set_hours,
#     "category": __get_interval_set_category,
#     "start": __get_minimum_start,
# }

config, interval_set = parse_stdin(sys.stdin, annotate={
    "hours": __get_interval_set_hours,
})

per_month = interval_set.group(
    predicate=lambda i: i.format_start("%B %Y"),
    annotate={
        "month": __get_interval_set_month,
        "hours": __get_interval_set_hours,
        "start": __get_minimum_start,
    },
    sort=lambda s: s.month
)

print("Tree summary, total hours: %s" % (interval_set.hours))
for monthly_set in per_month:
    print("    %s for %s hours" % (monthly_set.description, monthly_set.hours))
    per_ticket = monthly_set.group(
        predicate=__get_interval_category,
        annotate={
            "month": get_common_interval_value(lambda i: i.format_start("%Y%m")),
            "category": get_common_interval_value(__get_interval_category),
            "hours": __get_interval_set_hours,
            "start": __get_minimum_start,
        },
        sort=cmp_to_key(__compare_isets)
    )
    for ticket_set in per_ticket:
        print("        %s @%s for %s hours" % (ticket_set.description, ticket_set.start, ticket_set.hours))
        for interval in ticket_set:
            hours = __get_interval_hours(interval)
            print("            %s @%s for %s hours (#%s)" % (
                interval.annotation,
                interval.format_start("%Y-%m-%d %H:%M", zoneinfo),
                hours,
                interval.id,
            ))


print("\nSummary CSV")
csv_group = interval_set.group(
    predicate=lambda i: "%s %s" % (i.format_start("%B %Y"), __get_interval_category(i)),
    annotate={
        "year": get_common_interval_value(lambda i: i.format_start("%Y")),
        "month": get_common_interval_value(lambda i: i.format_start("%B")),
        "category": get_common_interval_value(__get_interval_category),
        "hours": __get_interval_set_hours,
        "start": __get_minimum_start,
    },
    sort=cmp_to_key(__compare_isets)
).csv(sys.stdout, ['year', 'month', 'hours', 'category'])


print("\nDetailed CSV")
csv_group = interval_set.group(
    predicate=lambda i: i.id,
    annotate={
        "category": get_common_interval_value(__get_interval_category),
        "description": get_common_interval_value(lambda i: i.annotation),
        "datetime": get_common_interval_value(lambda i: i.period[0].astimezone(zoneinfo).strftime('%Y%m%d %H:%M')),
        "hours": __get_interval_set_hours,
        "start": __get_minimum_start,
    },
    sort=__get_minimum_start,
).csv(sys.stdout, ['datetime', 'hours', 'category', 'description'])
