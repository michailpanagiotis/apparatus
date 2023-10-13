#!/usr/bin/python3

from datetime import timedelta
from intervals import Interval, IntervalSet, PointInTime
import csv
import json
import re
import subprocess
import sys


def __read_records():
    records = [json.loads(line) for line in sys.stdin]
    return records


def __get_tickets(records):
    tickets = set()
    for record in records:
        ticket = record["meta"]["ticket"]
        if ticket:
            tickets.add(ticket)

    return tickets


def __read_jiras(records):
    tickets = __get_tickets(records)
    if len(tickets) == 0:
        return {}
    res = subprocess.run(
        [
            "jira",
            "issue",
            "list",
            "--plain",
            "--columns",
            "type,key,status,priority,created,updated,summary,assignee",
            "--no-truncate",
            "-q",
            "key IN (%s)" % (",".join(tickets)),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    reader = csv.DictReader(
        [re.sub("[\t]+", "\t", s) for s in res.stdout.splitlines()], delimiter="\t"
    )
    jiras = {row["KEY"]: row for row in reader}
    return jiras


def __parse_interval(record, jira_tickets):
    meta = record["meta"]
    commit = record["commit"][:8]

    jira_ticket = (
        jira_tickets[meta["ticket"]] if meta["ticket"] in jira_tickets else None
    )

    tags = []
    if meta["is_deployment"]:
        tags.append("Deployment")
    elif meta["ticket"]:
        tags.append(meta["ticket"])
    else:
        tags.append("Adhoc")
    interval = (
        PointInTime(
            id=commit,
            at=record["at"],
            tags=tags,
            annotation="%s %s" % (jira_ticket["KEY"], jira_ticket["SUMMARY"])
            if jira_ticket
            else meta["branch"],
            meta={k: meta[k] for k in ["branch", "date", "ticket"]},
        )
        .to_interval(
            minimum_span_before=timedelta(minutes=30)
            if meta["is_ticket"]
            else timedelta(minutes=0),
            minimum_span_after=timedelta(minutes=30)
            if meta["is_deployment"]
            else timedelta(minutes=0),
        )
        .quantize()
    )
    return interval


def parse_intervals(records):
    jira_tickets = __read_jiras(stdin_records)
    intervals = [__parse_interval(record, jira_tickets) for record in records]
    return intervals


stdin_records = __read_records()

intervals = parse_intervals(stdin_records)


# # for ln in res.stdout:
# #     print(str(ln))
#

# intervals = [
#     x.clone(annotation=jira_tickets[x.meta["ticket"]]["SUMMARY"])
#     if x.meta["ticket"] in jira_tickets
#     else x
#     for x in intervals
# ]
#
# for interval in intervals:
#     ticket_key = interval.meta["ticket"]
#     if ticket_key in jira_tickets:
#         interval.clone(annotation=jira_tickets[ticket_key]["SUMMARY"])


date_groups = Interval.group(
    intervals, lambda x: x.meta["date"], sort=lambda s: s.description
)

for per_date in date_groups:
    print("  %s " % (per_date.description))
    branch_groups = Interval.group(
        per_date.get_intervals(), lambda x: x.annotation, sort=lambda s: s.description
    )

    for per_branch in branch_groups:
        print("    %s " % (per_branch.description))
        for interval in per_branch.merge().get_intervals():
            print("          ", interval, interval.tags, interval.meta)
