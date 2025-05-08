#!/bin/bash

~/.apparatus/scripts/oauth2/get_access_token.sh michailpanagiotis@gmail.com
mbsync -a -c ~/.config/mbsync/michailpanagiotis@gmail.com

~/.apparatus/scripts/oauth2/get_access_token.sh panos@talentdesk.io
mbsync -a -c ~/.config/mbsync/panos@talentdesk.io

~/.apparatus/scripts/oauth2/get_access_token.sh panos_wert@hotmail.com
mbsync -a -c ~/.config/mbsync/panos_wert@hotmail.com
