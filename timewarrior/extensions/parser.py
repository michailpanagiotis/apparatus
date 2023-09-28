#!/usr/bin/env python3
import sys
import re
import json
import datetime
from dateutil import parser
from functools import reduce
from typing import NamedTuple
from collections import defaultdict

class Interval(NamedTuple):
    id: int
    start: datetime
    end: datetime
    tags: list[str]
    annotation: str = ""

    def format_start(self, format, timezone=None):
        if not timezone:
            return parser.isoparse(self.start).strftime(format)
        return parser.isoparse(self.start).astimezone(timezone).strftime(format)

    @property
    def period(self):
        return (parser.isoparse(self.start), parser.isoparse(self.end))

    @property
    def seconds(self):
        (start, end) = self.period
        return (end - start).seconds


class IntervalSet:
    def __init__(self, intervals, description_fn=lambda x: '', common_metadata=None):
        self.__all_intervals = [
            Interval(**x) if isinstance(x, dict) else x for x in intervals
        ]
        self.__description_fn = description_fn
        self.description = self.get_common_value(description_fn, 'description')
        self.set_common_metadata(common_metadata)

    def __getitem__(self, index):
        return self.__all_intervals[index]

    def set_common_metadata(self, common_metadata=None):
        if common_metadata is None:
            self.metadata = tuple()
        else:
            Metadata = NamedTuple('Metadata', [(key, str) for key in common_metadata.keys()])

            self.metadata = Metadata(**{key: fn(self) for key, fn in common_metadata.items()})

    def aggregate(self, interval_fn, initial_value):
        return reduce(lambda acc, curr: acc + interval_fn(curr), self.__all_intervals, initial_value)

    def min(self, interval_fn):
        min = None
        for interval in self.__all_intervals:
            value = interval_fn(interval)
            if min is None or value < min:
                min = value
        return min

    def get_common_value(self, fn, key=None):
        if not callable(fn):
            raise Exception("expecting a callable for fn for %s" % key)
        values = {fn(i) for i in self.__all_intervals}
        if len(values) != 1:
            raise Exception('expecting just one common value for %s' % key)
        return values.pop()

    def group(
        self,
        predicate,
        group_sort=lambda x: x.description,
        common_metadata=None,
    ):
        if not callable(predicate):
            raise Exception("expecting a callable for predicate")
        indexes = defaultdict(list)
        for elem in self.__all_intervals:
            indexes[predicate(elem)].append(elem)
        sets = [
            IntervalSet(intervals, predicate, common_metadata)
            for intervals in indexes.values()
        ]
        sets.sort(key=group_sort)
        return sets

def parse_stdin(stdin, common_metadata=None):
    config = {}
    config_regex = re.compile("^(.*): (.*)$")
    # read config lines
    for line in stdin:
        if re.match("^\s+$", line):
            # configuration data are complete, proceed to reading the JSON body
            break

        match = config_regex.match(line)
        if match:
            match = config_regex.match(line)
            if match:
                path_components = match.group(1).split('.')
                rv = config
                for key in path_components[:-1]:
                    rv = rv.setdefault(key, {})
                rv[path_components[-1]]=match.group(2)

    # read intervals json
    intervals = IntervalSet(
        intervals=json.loads(''.join(line for line in sys.stdin)),
        common_metadata = common_metadata,
    )
    return config, intervals
