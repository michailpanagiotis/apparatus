Expunge None
Create Near
SyncState *

IMAPAccount panos_wert@hotmail.com
Host outlook.office365.com
User panos_wert@hotmail.com
AuthMechs XOAUTH2
PassCmd "gpg2 -q --for-your-eyes-only --no-tty -d ~/.config/oauth2c/panos_wert@hotmail.com.gpg"
SSLType IMAPS
SSLVersions TLSv1.1 TLSv1.2

IMAPStore remote-store
Account panos_wert@hotmail.com

MaildirStore local-store
Path ~/mail/panos_wert@hotmail.com/
Inbox ~/mail/panos_wert@hotmail.com/Inbox
SubFolders Verbatim

MaildirStore archive
Path ~/mail/panos_wert@hotmail.com/

Channel archive
Far ":remote-store:Archive"
Near ":archive:Archive"
Sync All

Channel trash
Far ":remote-store:Deleted"
Near ":archive:Trash"
Sync Pull

Channel drafts
Far ":remote-store:Drafts"
Near ":local-store:Drafts"
Sync Pull
Expunge Both

Channel sent
Far ":remote-store:Sent"
Near ":local-store:Sent"
Sync Pull
Expunge Both

Channel inbox
Far ":remote-store:INBOX"
Near ":local-store:Inbox"
Sync All
Expunge Both

Group panos_wert@hotmail.com
Channel trash
Channel inbox
Channel drafts
Channel sent
Channel archive
