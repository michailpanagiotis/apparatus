#!/bin/bash

echo "Importing new mail"
notmuch new

echo "Running global tag additions to tag new mail"

echo "Tagging accounts"
notmuch tag +gmail folder:'"/gmail/"' and not folder:'"/gmail/\[Gmail\].Sent Mail/"' and not tag:gmail
notmuch tag +td folder:'"/talentdesk/"' and not folder:'"/talentdesk/\[Gmail\].Sent Mail/"' and not tag:td

echo "Adding gmail labels"
notmuch tag +gmail-sent folder:'"/gmail/\[Gmail\].Sent Mail/"' and not tag:gmail-sent
notmuch tag +td-sent folder:'"/talentdesk/\[Gmail\].Sent Mail/"' and not tag:td-sent

notmuch tag +draft folder:'"/.*/\[Gmail\].Drafts/"' and not tag:draft
notmuch tag +spam folder:'"/.*/\[Gmail\].Spam/"' and not tag:spam
notmuch tag +trash folder:'"/.*/\[Gmail\].Trash/"' and not tag:trash

echo "Tagging inbound email"
# Note mail sent specifically to me (excluding bug mail)
notmuch tag +to-me to:michailpanagiotis@gmail.com and not tag:to-me
notmuch tag +to-me to:panos@talentdesk.io and not tag:to-me
notmuch tag +to-me to:panos@toptal.com and not tag:to-me
notmuch tag +to-me to:michai@ceid.upatras.gr and not tag:to-me
notmuch tag +to-me to:panos_wert@hotmail.com and not tag:to-me

echo "Tagging outbound email"
# And note all mail sent from me
notmuch tag +sent from:michailpanagiotis@gmail.com and not tag:sent
notmuch tag +sent from:panos@talentdesk.io and not tag:sent
notmuch tag +sent from:panos@toptal.com and not tag:sent
notmuch tag +sent from:michai@ceid.upatras.gr and not tag:sent
notmuch tag +sent from:panos_wert@hotmail.com and not tag:sent

echo "Tagging known services"
notmuch tag +td-info from:info@talentdesk.io and not tag:td-info
notmuch tag +jira from:jira@talentdesk.atlassian.net and not tag:jira

echo "Done."
