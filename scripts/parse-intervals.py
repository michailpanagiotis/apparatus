#!/usr/bin/python3

from datetime import timedelta
from intervals import Interval, IntervalSet, PointInTime
import json
import sys

def parse_interval(line):
    info = json.loads(line)
    meta = info["meta"]
    commit = info["commit"][:8]

    tags = []
    is_deployment = meta["is_deployment"]
    if meta["is_deployment"]:
        tags.append("Deployment")
    elif meta["ticket"]:
        tags.append(meta["ticket"])
    else:
        tags.append('Adhoc')
    interval = PointInTime(
        id=commit,
        at=info["at"],
        tags=tags,
        annotation=meta["branch"],
        meta={k: meta[k] for k in ["branch", "date", "ticket"]},
    ).to_interval(
        minimum_span_before=timedelta(minutes=30) if meta["is_ticket"] else timedelta(minutes=0),
        minimum_span_after=timedelta(minutes=30) if meta["is_deployment"] else timedelta(minutes=0),
    ).quantize()
    return interval

intervals = [parse_interval(line) for line in sys.stdin]

s = Interval.group(intervals, lambda x: x.meta["branch"], sort=lambda s: s.description)

for per_branch in s:
    print("  %s " % (per_branch.description))
    for interval in per_branch.merge().get_intervals():
        print("        ", interval, interval.tags, interval.meta)

