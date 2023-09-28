#!/usr/bin/env python3
import sys
import re
import json
import datetime

def parse_interval_lines(stdin_interval_lines):
    from typing import NamedTuple
    class Interval(NamedTuple):
        id: int
        start: datetime
        end: datetime
        tags: list[str]
        annotation: str = ""

    json_intervals = json.loads(''.join(line for line in stdin_interval_lines))
    return {i["id"]: Interval(**i) for i in json_intervals}

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

config, intervals = parse_stdin(sys.stdin)
print(' '.join('@%s' % x.id for x in intervals.values()))
