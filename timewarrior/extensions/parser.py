#!/usr/bin/env python3
import sys
import re
import json
import datetime
import dataclasses as dc
from csv import DictWriter
from dateutil import parser
from functools import reduce
from collections import defaultdict

@dc.dataclass(unsafe_hash=True)
class Interval():
    id: int
    start: datetime
    end: datetime
    tags: list[str]
    annotation: str = ""

    def __post_init__(self):
        self.start = parser.isoparse(self.start)
        self.end = parser.isoparse(self.end)

    @property
    def total_seconds(self):
        return (self.end - self.start).seconds

    @property
    def total_minutes(self):
        return self.total_seconds // 60

    @property
    def total_hours(self):
        return self.total_seconds // 3600


class IntervalSet:
    def __init__(self, intervals, predicate=lambda x: '', annotate=None):
        self.__all_intervals = [
            Interval(**x) if isinstance(x, dict) else x for x in intervals
        ]
        self.__id = self.get_common_value(predicate)

        self.__metadata = {
            "description": self.__id,
            "start": self.min(lambda i: i.start),
            "total_seconds": self.aggregate(lambda i: i.total_seconds, 0),
            "total_minutes": self.aggregate(lambda i: i.total_minutes, 0),
            "total_hours": self.aggregate(lambda i: i.total_hours, 0),
        }

        if annotate:
            self.__metadata.update({key: fn(self) for key, fn in annotate.items()})


    def __getitem__(self, index):
        return self.__all_intervals[index]

    def __getattr__(self, name):
        if name in self.__metadata:
            return self.__metadata[name]
        else:
            # Default behaviour
            raise AttributeError

    def get_metadata_keys(self):
        return set(self.__metadata.keys())

    def aggregate(self, interval_fn, initial_value):
        return reduce(lambda acc, curr: acc + interval_fn(curr), self.__all_intervals, initial_value)

    def min(self, interval_fn):
        min = None
        for interval in self.__all_intervals:
            value = interval_fn(interval)
            if min is None or value < min:
                min = value
        return min

    def distinct(self, interval_fn):
        if not callable(interval_fn):
            raise Exception("expecting a callable for fn")
        return {interval_fn(i) for i in self.__all_intervals}

    def get_common_value(self, fn,):
        values = self.distinct(fn)
        if len(values) != 1:
            raise Exception('expecting just one common value')
        return values.pop()

    def group(self, predicate=lambda x: x.id, annotate=None, sort=None):
        indexes = defaultdict(list)
        for elem in self.__all_intervals:
            indexes[predicate(elem)].append(elem)
        group = [
            IntervalSet(intervals, predicate, annotate)
            for intervals in indexes.values()
        ]
        if sort:
            return IntervalGrouping(sorted(group, key=sort))
        return IntervalGrouping(group)

    def csv(self, writer):
        writer.writerow({k: getattr(self, k) for k in writer.fieldnames})

class IntervalGrouping:
    def __init__(self, children):
        self.__children=children

    def __getitem__(self, index):
        return self.__children[index]

    def csv(self, stream, fieldnames):
        writer = DictWriter(sys.stdout, fieldnames)
        writer.writeheader()

        for s in self.__children:
            s.csv(writer)


def parse_stdin(stdin, annotate=None):
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
        annotate = annotate,
    )
    return config, intervals
