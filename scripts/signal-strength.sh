#!/bin/bash

# create a descending signal strength list of detected WLAN SSID.
# The smaller numeric negative RSSI value is the strongest received
# signal strength.

AIRPATH="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources"
printf '%s\t%s\n' "RSSI" "SSID"
${AIRPATH}/airport -s | \
perl -lne '$_ =~ s/^\s+//g;' \
-lne '$_ =~ /^([A-Za-z0-9\_\- ]+)\s*.*([-]\d+).*$/ && print "$2\t" . substr($1,0,-3)' | \
sort -rn
exit 0
