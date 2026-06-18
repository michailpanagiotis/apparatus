#!/usr/bin/env bash
set -e

usage() {
  cat <<HELP_USAGE
Usage:
  $0 <JIRA_COMMENT_URL>

Example:
  $0 "https://talentdesk.atlassian.net/browse/BT-1234?focusedCommentId=67890"
HELP_USAGE
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

url="$1"

# Extract issue key (e.g. BT-1234) from the URL path
issue_key=$(printf '%s' "$url" | grep -oP '(?<=/browse/)[A-Z]+-[0-9]+')
# Extract comment ID from focusedCommentId query param
comment_id=$(printf '%s' "$url" | grep -oP '(?<=focusedCommentId=)[0-9]+')

if [ -z "$issue_key" ]; then
  echo "Error: could not parse issue key from URL" >&2
  exit 1
fi

if [ -z "$comment_id" ]; then
  echo "Error: could not parse focusedCommentId from URL" >&2
  exit 1
fi

response=$(curl -s --request GET "${JIRA_API_URL}/issue/${issue_key}/comment/${comment_id}" \
  -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json")

# Extract author and created date
author=$(printf '%s' "$response" | jq -r '.author.displayName // "Unknown"')
created=$(printf '%s' "$response" | jq -r '.created // ""' | cut -c1-16 | tr 'T' ' ')

# Body is Jira wiki markup (plain string in API v2)
body=$(printf '%s' "$response" | jq -r '.body // ""')

printf '%s (%s):\n%s\n' "$author" "$created" "$body"
