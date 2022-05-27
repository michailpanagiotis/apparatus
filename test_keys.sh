#!/bin/bash

echo 'Stopping service xkeysnail'
sudo systemctl stop xkeysnail
sudo xkeysnail --watch ./kinto/kinto.py
echo 'Starting service xkeysnail'
sudo systemctl start xkeysnail
echo 'Done'

