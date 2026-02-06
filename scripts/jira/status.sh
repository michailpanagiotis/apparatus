#!/usr/bin/env bash
set -e

# Load QA tickets from github script
qa_tickets_file="/tmp/qa_jira_tickets"

# Cache merged branches for performance
branches_merged_master=$(git branch --merged master 2>/dev/null || echo "")
branches_merged_staging2=$(git branch --merged staging2 2>/dev/null || echo "")

get_merge_status() {
  local key="$1"
  local markers=""

  # Check if any branch containing the ticket name is merged to master
  if echo "$branches_merged_master" | grep -qi "$key"; then
    markers="[master]"
  # Check if any branch containing the ticket name is merged to staging2
  elif echo "$branches_merged_staging2" | grep -qi "$key"; then
    markers="[staging2]"
  fi

  echo "$markers"
}

print_ticket_with_qa_marker() {
  while read -r key; do
    url="https://talentdesk.atlassian.net/browse/${key}"
    merge_status=$(get_merge_status "$key")
    qa_marker=""
    if [[ -f "$qa_tickets_file" ]] && grep -qx "$key" "$qa_tickets_file" 2>/dev/null; then
      qa_marker=" [QA]"
    fi
    printf '\t%s%s%s\n' "$url" "${merge_status:+ $merge_status}" "$qa_marker"
  done
}

echo 'JIRA'
echo '  My bugs:'

curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key"], "jql":"status NOT IN (Done, Closed) AND project IN (BT) AND assignee = currentUser() AND status != \"Blocked / On Hold\" ORDER BY created DESC"}' | jq -r '.issues[].key' | print_ticket_with_qa_marker


echo '  My features:'
curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key"], "jql":"status NOT IN (Done, Closed) AND project IN (PAYM) AND assignee = currentUser() AND status != \"Blocked / On Hold\" ORDER BY created DESC"}' | jq -r '.issues[].key' | print_ticket_with_qa_marker

if [ ! -z "${SHOW_BUGBOARD}" ];
then
    echo '  Bug board:'
    curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key","url","priority","assignee"], "jql":"status NOT IN (Done, Closed) AND project IN (BT) AND assignee IN (currentUser(), empty) AND type != \"New Feature\" AND status != \"Blocked / On Hold\" AND \"Team[Dropdown]\" = \"Payments development\" ORDER BY created DESC"}' | jq -r '.issues[] | "\(.key)\t\(.fields.priority.name)\t\(.fields.assignee.emailAddress // "")"' | while IFS=$'\t' read -r key priority assignee_email; do
      url="https://talentdesk.atlassian.net/browse/${key}"
      mine_marker=""
      qa_marker=""
      merge_status=$(get_merge_status "$key")
      [[ "$assignee_email" == "$JIRA_API_USER" ]] && mine_marker=" ▶"
      [[ -f "$qa_tickets_file" ]] && grep -qx "$key" "$qa_tickets_file" 2>/dev/null && qa_marker=" [QA]"
      printf '\t%s %s%s%s%s\n' "$url" "$priority" "$mine_marker" "${merge_status:+ $merge_status}" "$qa_marker"
    done
fi

print_weekly_tickets() {
  while read -r line; do
    key=$(printf '%s' "$line" | cut -f1)
    summary_b64=$(printf '%s' "$line" | cut -f2)
    url="https://talentdesk.atlassian.net/browse/${key}"
    summary=$(printf '%s' "$summary_b64" | base64 -d 2>/dev/null || echo "")
    printf '\t%s\n' "$url"
    printf '\t\t%s\n' "$summary"
  done
}

if [ ! -z "${SHOW_WEEK}" ];
then
    # Fetch working tickets (non-Done/Closed, non-QA Testing)
    working_tickets=$(curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key","summary"], "jql":"assignee changed TO currentUser() AFTER startOfWeek() AND status NOT IN (Done, Closed, \"QA Testing\") AND project IN (BT, PAYM) ORDER BY updated DESC"}' | jq -r '.issues[] | "\(.key)\t\((.fields.summary // "") | @base64)"')

    # Fetch QA Testing tickets separately
    qa_tickets=$(curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key","summary"], "jql":"assignee changed TO currentUser() AFTER startOfWeek() AND status = \"QA Testing\" AND project IN (BT, PAYM) ORDER BY updated DESC"}' | jq -r '.issues[] | "\(.key)\t\((.fields.summary // "") | @base64)"')

    echo '  Working on this week:'
    # Print non-QA working tickets
    echo "$working_tickets" | print_weekly_tickets
    # Print QA tickets that are NOT merged to master
    echo "$qa_tickets" | while read -r line; do
      [[ -z "$line" ]] && continue
      key=$(printf '%s' "$line" | cut -f1)
      if ! echo "$branches_merged_master" | grep -qi "$key"; then
        summary_b64=$(printf '%s' "$line" | cut -f2)
        url="https://talentdesk.atlassian.net/browse/${key}"
        summary=$(printf '%s' "$summary_b64" | base64 -d 2>/dev/null || echo "")
        printf '\t%s\n' "$url"
        printf '\t\t%s\n' "$summary"
      fi
    done

    echo '  Done this week:'
    # Print actual Done/Closed tickets
    curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key","summary"], "jql":"assignee changed TO currentUser() AFTER startOfWeek() AND status IN (Done, Closed) AND project IN (BT, PAYM) ORDER BY updated DESC"}' | jq -r '.issues[] | "\(.key)\t\((.fields.summary // "") | @base64)"' | print_weekly_tickets
    # Print QA tickets that ARE merged to master
    echo "$qa_tickets" | while read -r line; do
      [[ -z "$line" ]] && continue
      key=$(printf '%s' "$line" | cut -f1)
      if echo "$branches_merged_master" | grep -qi "$key"; then
        summary_b64=$(printf '%s' "$line" | cut -f2)
        url="https://talentdesk.atlassian.net/browse/${key}"
        summary=$(printf '%s' "$summary_b64" | base64 -d 2>/dev/null || echo "")
        printf '\t%s\n' "$url"
        printf '\t\t%s\n' "$summary"
      fi
    done
fi
