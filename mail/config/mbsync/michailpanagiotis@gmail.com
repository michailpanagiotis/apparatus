Expunge None
Create Near
SyncState *

IMAPAccount michailpanagiotis@gmail.com
Host imap.gmail.com
User michailpanagiotis@gmail.com
AuthMechs XOAUTH2
PassCmd "gpg2 -q --for-your-eyes-only --no-tty -d ~/.config/oauth2c/michailpanagiotis@gmail.com.gpg"
SSLType IMAPS
SSLVersions TLSv1.1 TLSv1.2

IMAPStore remote-store
Account michailpanagiotis@gmail.com

MaildirStore local-store
Path ~/mail/michailpanagiotis@gmail.com/
Inbox ~/mail/michailpanagiotis@gmail.com/Inbox
SubFolders Verbatim

MaildirStore archive
Path ~/mail/michailpanagiotis@gmail.com/

Channel archive
Far ":remote-store:[Gmail]/All Mail"
Near ":archive:Archive"
Sync All

Channel trash
Far ":remote-store:[Gmail]/Trash"
Near ":archive:Trash"
Sync Pull

Channel drafts
Far ":remote-store:[Gmail]/Drafts"
Near ":local-store:Drafts"
Sync Pull
Expunge Both

Channel sent
Far ":remote-store:[Gmail]/Sent Mail"
Near ":local-store:Sent"
Sync Pull
Expunge Both

Channel inbox
Far ":remote-store:INBOX"
Near ":local-store:Inbox"
Sync All
Expunge Both

Group michailpanagiotis@gmail.com
Channel trash
Channel inbox
Channel drafts
Channel sent
Channel archive
