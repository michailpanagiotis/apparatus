#!/usr/bin/env bash
set -e

read -p "Enter email: " EMAIL

mkdir -p ~/.config/mbsync

# install isync/mbsync https://isync.sourceforge.io/

# install oama
nix-env -iA nixpkgs.oama
nix-env -iA nixpkgs.cyrus-sasl-xoauth2
apt-get install libsasl2-modules-kdexoauth2


cat > /etc/wireguard/wg0.conf <<- EOM
Expunge None
Create Near
SyncState *

IMAPAccount ${EMAIL}
Host imap.gmail.com
User ${EMAIL}
AuthMechs XOAUTH2
PassCmd "oama access ${EMAIL}"
SSLType IMAPS
SSLVersions TLSv1.1 TLSv1.2

IMAPStore remote-store
Account ${EMAIL}

MaildirStore local-store
Path ~/mail/${EMAIL}/
Inbox ~/mail/${EMAIL}/Inbox
SubFolders Verbatim

MaildirStore archive
Path ~/mail/${EMAIL}/

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

Group ${EMAIL}
Channel trash
Channel inbox
Channel drafts
Channel sent
Channel archive
EOM
