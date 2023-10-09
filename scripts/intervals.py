import sys
import re
import json
from datetime import datetime, timedelta
from csv import DictWriter
from functools import reduce
from typing import NamedTuple
from collections import defaultdict

def time_mod(time, delta, epoch=None):
    if epoch is None:
        epoch = datetime(1970, 1, 1, tzinfo=time.tzinfo)
    return (time - epoch) % delta

def time_round(time, delta, epoch=None):
    mod = time_mod(time, delta, epoch)
    if mod < delta / 2:
       return time - mod
    return time + (delta - mod)

def time_floor(time, delta, epoch=None):
    mod = time_mod(time, delta, epoch)
    return time - mod

def time_ceil(time, delta, epoch=None):
    mod = time_mod(time, delta, epoch)
    if mod:
        return time + (delta - mod)
    return time

class PointInTime(NamedTuple):
    at: datetime
    tags: list[str] = []
    annotation: str = ""
    meta: dict = {}
    id: int = None

    def _quantize(self, step=60):
        return PointInTime(
            id=self.id,
            at=at.self.at,
            tags=self.tags,
            annotation=self.annotation,
        )

    def to_interval(
        self,
        minimum_span_before=timedelta(minutes=0),
        minimum_span_after=timedelta(minutes=0),
        quantize_step_down=timedelta(minutes=15),
        quantize_step_up=timedelta(minutes=15),
    ):
        at = datetime.fromisoformat(self.at)
        start = time_floor(at - minimum_span_before, quantize_step_down).isoformat()
        end = time_ceil(at + minimum_span_after, quantize_step_up).isoformat()
        return Interval(
            id=self.id,
            start=start,
            end=end,
            tags=self.tags,
            annotation=self.annotation,
            meta=self.meta,
        )

class Interval(NamedTuple):
    start: datetime
    end: datetime
    tags: list[str]
    annotation: str = ""
    meta: dict = {}
    id: int = None

    def __str__(self):
        day_format = "%Y%m%d"
        time_format = "%H%M"
        full_format = "%Y%m%d %H:%M"
        start, end = self.period
        start_day = start.strftime(day_format)
        end_day = end.strftime(day_format)
        if start_day == end_day:
            start_fmt = start.strftime(time_format)
            end_fmt = end.strftime(time_format)
            return 'Interval %s %s->%s' % (start_day, start_fmt, end_fmt)

        start_fmt = start.strftime(full_format)
        end_fmt = end.strftime(full_format)
        return 'Interval %s->%s' % (start_fmt, end_fmt)

    @property
    def period(self):
        return (datetime.fromisoformat(self.start), datetime.fromisoformat(self.end))

    @property
    def total_seconds(self):
        (start, end) = self.period
        return (end - start).seconds

    @property
    def total_minutes(self):
        (start, end) = self.period
        return (end - start).seconds // 60

    @property
    def total_hours(self):
        (start, end) = self.period
        return (end - start).seconds // 3600

    @classmethod
    def group(cls, intervals, predicate=lambda x: x.id, annotate=None, sort=None):
        indexes = defaultdict(list)
        for elem in intervals:
            indexes[predicate(elem)].append(elem)
        group = [
            IntervalSet(intervals, predicate, annotate)
            for intervals in indexes.values()
        ]
        if sort:
            return IntervalGrouping(sorted(group, key=sort))
        return IntervalGrouping(group)

    def overlaps(self, other):
        start, end = self.period
        other_start, other_end = other.period
        if start == other_start:
            return True
        if start < other_start:
            if end < other_start:
                return False
            return True
        # start > other_start
        if other_end < start:
            return False
        return True

    def merge(self, other):
        min_start = min(self.period[0], other.period[0]).isoformat()
        max_end = max(self.period[1], other.period[1]).isoformat()
        return Interval(
            id = None,
            start = min_start,
            end = max_end,
            tags = [x for x in self.tags if x in other.tags],
            annotation = self.annotation,
            meta = {k: v for (k, v) in self.meta.items() if k in other.meta and other.meta[k] == v},
        )



class IntervalSet:
    def __init__(self, intervals, predicate=lambda x: '', annotate=None):
        self.__all_intervals = [
            Interval(**x) if isinstance(x, dict) else x for x in intervals
        ]
        self.__id = self.get_common_value(predicate)
        self.__predicate = predicate
        self.__annotate = annotate

        self.__metadata = {
            "description": self.__id,
            "start": self.min(lambda i: i.period[0]),
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

    def merge(self):
        intervals = sorted(self.__all_intervals, key=lambda i: i.period[0])
        if len(intervals) == 0:
            return IntervalSet([])

        merged = [intervals[0]]

        for current in intervals:
            previous = merged[-1]
            if current.overlaps(previous):
                merged[-1] = current.merge(merged[-1])
            else:
                merged.append(current)

        return IntervalSet(merged, self.__predicate, self.__annotate)


    def get_intervals(self):
        return self.__all_intervals

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
        return Interval.group(self.__all_intervals, predicate, annotate, sort)

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
