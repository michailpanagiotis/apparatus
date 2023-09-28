#!/usr/bin/env python3
import sys
import re
import json
import datetime
from dateutil import parser
from itertools import groupby
from typing import NamedTuple

class GroupingDefinition(NamedTuple):
    predicate: callable
    description_fn: callable

def parse_interval_lines(stdin_interval_lines):
    class IntervalSet:
        def __init__(self, intervals=None, description_fn = None):
            self.__all_intervals = list(intervals)

            if not description_fn:
                raise Exception('description_fn is required')

            descriptions = {description_fn(i) for i in self.__all_intervals}
            if len(descriptions) != 1:
                raise Exception('expecting just one description')
            self._description = descriptions.pop()

        def to_list(self):
            return list(self.__all_intervals)

        def get_description(self):
            return self._description

        def __group_by(self, predicate, description_fn):
            if not callable(predicate):
                raise Exception("expecting a callable for predicate")
            if not callable(description_fn):
                raise Exception("expecting a callable for description")
            group = [IntervalSet(intervals, description_fn) for _, intervals in groupby(self.__all_intervals, predicate)]
            return group

        def group(self, grouping_definitions):
            definition = grouping_definitions[0]
            if not isinstance(definition, GroupingDefinition):
                raise Exception('expecting a GroupingDefinition')
            return self.__group_by(*definition)

    class IntervalNode:
        def __init__(self, children=None):
            self.__children=children


    class IntervalTreeOld:
        def from_stdin(intervals):
            return IntervalTreeOld(children=[IntervalTreeOld(interval=interval, description_fn=lambda i: 'stdin') for interval in intervals])

        def from_intervals(intervals,description_fn = None):
            return IntervalTreeOld(children=[IntervalTreeOld(interval=interval, description_fn=lambda i: 'stdin') for interval in intervals])

        def __init__(self, interval=None, children=tuple(), description_fn = None):
            if interval is not None and len(children) > 0:
                raise Exception('you can either define a single interval or children sets')

            self.__children = list(children)
            self.__all_intervals = [x for child in children for x in child.get_intervals()]

            if interval:
                self.__all_intervals.append(interval)

            if description_fn:
                descriptions = {description_fn(i) for i in self.__all_intervals}
                if len(descriptions) != 1:
                    raise Exception('expecting just one description')
                self._description = descriptions.pop()
            else:
                descriptions = {i.get_description() for i in children}
                if len(descriptions) != 1:
                    raise Exception('expecting just one description')
                self._description = descriptions.pop()

        def get_intervals(self):
            return list(self.__all_intervals)

        def to_list(self):
            return self.__all_intervals

        def get_description(self):
            return self._description

        def __group_by(self, predicate, description_fn):
            if not callable(predicate):
                raise Exception("expecting a callable for predicate")
            if not callable(description_fn):
                raise Exception("expecting a callable for description")
            return [IntervalTreeOld.from_intervals(intervals, description_fn) for _, intervals in groupby(self.__all_intervals, predicate)]

        def group(self, grouping_definitions):
            if len(grouping_definitions) > 0:
                definition = grouping_definitions[0]
                if not isinstance(definition, GroupingDefinition):
                    raise Exception('expecting a GroupingDefinition')
                return self.__group_by(*definition)
            return self


    class Interval(NamedTuple):
        id: int
        start: datetime
        end: datetime
        tags: list[str]
        annotation: str = ""

        def __get_period(self):
            return (parser.parse(self.start), parser.parse(self.end))

        def get_month(self):
            (start, end) = self.__get_period()
            return start.strftime('%Y%m')

        def get_formatted_month(self):
            (start, end) = self.__get_period()
            return start.strftime('%B %Y')

        def get_ticket(self):
            ticket = None
            for tag in self.tags:
                match = re.match("(SDK(?:-\d+)?\.SDK-\d+)", tag)
                if match:
                    ticket = match.group(1)
                    continue
            return ticket

        def get_description(self):
            ticket = self.get_ticket()
            if ticket:
                return '%s: %s' % (self.get_ticket(), self.annotation)
            else:
                return '%s %s' % (self.annotation, self.start)

    json_intervals = json.loads(''.join(line for line in stdin_interval_lines))
    return IntervalSet(intervals=(Interval(**i) for i in json_intervals), description_fn=lambda x: 'stdin')

def get_config_line_regex():
    return re.compile("^(.*): (.*)$")

def parse_config(stdin_config_lines):
    config = {}
    for line in stdin_config_lines:
        match = get_config_line_regex().match(line)
        if match:
            path_components = match.group(1).split('.')
            rv = config
            for key in path_components[:-1]:
                rv = rv.setdefault(key, {})
            rv[path_components[-1]]=match.group(2)
    return config

def parse_stdin(stdin):
    config_lines = []
    # read config lines
    for line in stdin:
        if re.match("^\s+$", line):
            # configuration data are complete, proceed to reading the JSON body
            break

        match = get_config_line_regex().match(line)
        if match:
            config_lines.append(line)

    config = parse_config(config_lines)
    intervals = parse_interval_lines(sys.stdin)
    return config, intervals
