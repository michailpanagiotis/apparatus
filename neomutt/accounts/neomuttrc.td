set smtp_url = "smtp://michailpanagiotis@smtp.gmail.com:587/"
set smtp_pass = "<PASSWORD>"
set from = "panos@talentdesk.io"
set realname = "Panos Michail"
set folder = "~/.mail/talentdesk"
set spoolfile = "+INBOX"
set postponed = "+[Gmail]/Draft"
set header_cache=~/.mutt/cache/headers
set message_cachedir = "~/.mutt/cache/bodies"

named-mailboxes Talentdesk +INBOX
mailboxes +INBOX +'[Gmail].Sent Mail' +[Gmail].Drafts +[Gmail].Spam +[Gmail].Trash

# smtp
set smtp_authenticators = "oauthbearer"
set smtp_oauth_refresh_command = "...."
set smtp_url = "smtp://panos@talentdesk.io@smtp.gmail.com:587/"
set realname = "Panos Michail"
