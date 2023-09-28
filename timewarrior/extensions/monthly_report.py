#!/usr/bin/env python3
import sys
from itertools import groupby

from parser import parse_stdin, GroupingDefinition

config, intervals = parse_stdin(sys.stdin)

grouped = intervals.group([
    GroupingDefinition(
        predicate=lambda i: i.get_month(),
        description_fn=lambda i: i.get_formatted_month(),
    )
])

for group in grouped:
    print(group.get_description())
    print(group.to_list())

raise Exception('stop')

for group in grouped:
    print(group.get_description())
    for interval in group.to_list():
        print('   ', interval.id, interval.get_description(), interval.tags, interval.start, interval.end)



for _, monthly_group in groupby(intervals.to_list(), key=lambda i: i.get_month()):
    monthly_intervals = list(monthly_group)
    month = monthly_intervals[0].get_formatted_month()
    print('=====', month)

    for description, group in groupby(monthly_intervals, key=lambda i: i.get_description()):
        print('  -----', description)
        # for interval in group:
        #     print('   ', interval.id, interval.get_description(), interval.tags, interval.start, interval.end)
