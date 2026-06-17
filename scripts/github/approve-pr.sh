#!/usr/bin/env bash
set -e

# Approve a pull request with a message.
#
# Usage:
#   approve-pr.sh <pr-number|pr-url> <message...>

if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: approve-pr.sh <pr-number|pr-url> <message...>" >&2
  exit 1
fi

# Accept either a bare number or a full PR URL.
pr_number=$(echo "$1" | grep -oE '[0-9]+' | tail -1)
if [[ -z "$pr_number" ]]; then
  echo "Could not parse a PR number from '$1'" >&2
  exit 1
fi
shift
message="$*"

hub api -X POST "/repos/TalentDeskApp/talentdesk.io/pulls/${pr_number}/reviews" \
  -f event=APPROVE \
  -f body="$message" \
  > /dev/null

echo "Approved PR #${pr_number}: ${message}"
