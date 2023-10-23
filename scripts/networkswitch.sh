#!/bin/bash

##Check signal strength of wifi and change if over a certain RSSI threshold.

THRESHOLD=-75
INTERFACE=en0

DATE=$(date "+%Y-%m-%dT%H:%M:%S")

##Get RSSI strength of WIFI and strip off the - charecter
signalStrength=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep CtlRSSI | awk '{print $2}'`

##Grab current connected WIFI SSID
wifiID=`networksetup -getairportnetwork $INTERFACE | cut -d ":" -f2 | sed 's/^[ t]*//'`

if [[ "$signalStrength" -gt $THRESHOLD ]]; then
    echo "$DATE Signal strength $signalStrength (above threshold), keeping $wifiID"
fi

if [[ "$signalStrength" -le $THRESHOLD && "$wifiID" = "Rutwert" ]]; then
    echo "$DATE Changing to Coswert wireless, RSSI signal out of threshold ($signalStrength)"
    networksetup -setairportnetwork $INTERFACE "Coswert"
elif [[ "$signalStrength" -le $THRESHOLD && "$wifiID" = "Coswert" ]]; then
    echo "$DATE Changing to Rutwert wireless, RSSI signal out of threshold ($signalStrength)"
    networksetup -setairportnetwork $INTERFACE "Rutwert"
fi
