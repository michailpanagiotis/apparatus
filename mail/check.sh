#!/bin/bash

mbsync -Va

notmuch new

notmuch tag --batch <<EOF
+inbox -- tag:new folder:INBOX
+spam  -- tag:new folder:Spam
+jira -inbox -- tag:new from:jira@talentdesk.atlassian.net

EOF

COUNT=$(notmuch count tag:tofilter and tag:unread)
notmuch tag -tofilter tag:tofilter
if [ ${COUNT} != 0 ]; then
	notify-send -h string:bgcolor:#3579a8 -h string:fgcolor:#d0d0d0 "MAIL MOTHERFUCKER !!" "${COUNT} new messages"
fi
