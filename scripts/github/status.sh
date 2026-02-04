#!/usr/bin/env bash
set -e

# Function to print PR URL and its HEAD branch name
print_pr_with_branch() {
  while read -r url; do
    if [[ -n "$url" ]]; then
      # Extract PR number from URL (e.g., https://github.com/TalentDeskApp/talentdesk.io/pull/28918)
      pr_number=$(echo "$url" | grep -oE '[0-9]+$')
      branch=$(hub api -X GET "/repos/TalentDeskApp/talentdesk.io/pulls/${pr_number}" | jq -r '.head.ref')
      printf '\t%s (%s)\n' "$url" "$branch"
    fi
  done
}

echo 'Github'
echo '  Requested:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:GeorgeLinardis author:willbell71 user-review-requested:@me' | jq -r '.items[].html_url' | print_pr_with_branch

echo '  Pending:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:required' | jq -r '.items[].html_url' | print_pr_with_branch

echo '  Denied:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:changes_requested' | jq -r '.items[].html_url' | print_pr_with_branch

echo '  Approved:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:approved' | jq -r '.items[].html_url' | print_pr_with_branch
