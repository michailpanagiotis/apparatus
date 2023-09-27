#!/usr/bin/env python3
import sys
from timewreport.parser import TimeWarriorParser

parser = TimeWarriorParser(sys.stdin)

totals = dict()

for interval in parser.get_intervals():
    annotation = interval.get_annotation()
    tracked = interval.get_duration()

    totals["annotation_%s" % annotation] = tracked

    for tag in interval.get_tags():
        if tag in totals:
            totals[tag] += tracked
        else:
            totals[tag] = tracked

# Determine largest tag width.
max_width = len('Total')

for tag in totals:
    if len(tag) > max_width:
        max_width = len(tag)

# Compose report header.
print('Total by Tag')
print('')

# Compose table header.
print('{:{width}} {:>10}'.format('Tag', 'Total', width=max_width))
print('{} {}'.format('-' * max_width, '----------'))

# Compose table rows.
grand_total = 0
for tag in sorted(totals):
    formatted = totals[tag].seconds
    grand_total += totals[tag].seconds
    print('{:{width}} {:10}'.format(tag, formatted, width=max_width))

# Compose total.
print('{} {}'.format(' ' * max_width, '----------'))
print('{:{width}} {:10}'.format('Total', grand_total, width=max_width))
