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

    def __get_period(self):
        return (parser.isoparse(self.start), parser.isoparse(self.end))

    def format_start(self, format):
        (start, end) = self.__get_period()
        return start.strftime(format)

    def get_duration(self):
        (start, end) = self.__get_period()
        return (end - start).seconds


class IntervalSet:
    def __init__(self, intervals=None, description_fn = lambda x: 'All'):
        self.__all_intervals = list(intervals)

        if not description_fn:
            raise Exception('description_fn is required')

        self.__description_fn = description_fn

        descriptions = {self.__description_fn(i) for i in self.__all_intervals}
        if len(descriptions) != 1:
            raise Exception('expecting just one description')
        self.__description = descriptions.pop()

    def to_list(self):
        return list(self.__all_intervals)

    def get_description(self):
        return self.__description

    def get_duration(self):
        return reduce(lambda acc, curr: acc + curr.get_duration(),self.__all_intervals, 0)

    def get_num_intervals(self):
        return len(self.__all_intervals)

    def get_hours(self):
        duration = self.get_duration()
        hours, remainder = divmod(duration, 3600)
        minutes, seconds = divmod(remainder, 60)
        return hours

    def group(self, predicate):
        if not callable(predicate):
            raise Exception("expecting a callable for predicate")
        indexes = defaultdict(list)
        for elem in self.__all_intervals:
            indexes[predicate(elem)].append(elem)
        return [
            IntervalSet(intervals, predicate)
            for intervals in indexes.values()
        ]

    def __str__(self):
        return "%s for %s hours" % (
            self.get_description(),
            self.get_hours(),
        )

def parse_stdin(stdin):
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
        intervals=(Interval(**i) for i in json.loads(''.join(line for line in sys.stdin))),
    )
    return config, intervals
