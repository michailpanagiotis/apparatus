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
    [[ -z "$line" ]] && continue
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
    # SHOW_WEEK accepts:
    #   - A date range: "2026-02-02:2026-02-07" (inclusive, shows that exact period)
    #   - A number of weeks back: 0 = current week, 1 = last week, 2 = two weeks ago
    #   - Any other truthy value (e.g. "true"): current week
    if [[ "$SHOW_WEEK" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}):([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
      start_date="${BASH_REMATCH[1]}"
      end_date="${BASH_REMATCH[2]}"
      # JIRA BEFORE is exclusive, so add 1 day to include the end date
      end_date_exclusive=$(date -d "${end_date} + 1 day" +%Y-%m-%d)
      after_clause="AFTER \\\"${start_date}\\\""
      before_clause="BEFORE \\\"${end_date_exclusive}\\\""
      week_label="${start_date} to ${end_date}"
    else
      week_offset="${SHOW_WEEK}"
      if ! [[ "$week_offset" =~ ^[0-9]+$ ]]; then
        week_offset=0
      fi

      if [ "$week_offset" -eq 0 ]; then
        after_clause="AFTER startOfWeek()"
        before_clause=""
        week_label="this week"
      else
        after_clause="AFTER startOfWeek(-${week_offset}w)"
        before_end=$((week_offset - 1))
        if [ "$before_end" -eq 0 ]; then
          before_clause="BEFORE startOfWeek()"
        else
          before_clause="BEFORE startOfWeek(-${before_end}w)"
        fi
        week_label="${week_offset} week(s) ago"
      fi
    fi

    # Fetch working tickets (non-Done/Closed, non-QA Testing)
    working_tickets=$(curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json "{\"fields\": [\"key\",\"summary\"], \"jql\":\"assignee changed TO currentUser() ${after_clause}${before_clause:+ ${before_clause}} AND status NOT IN (Done, Closed, \\\"QA Testing\\\") AND project IN (BT, PAYM) ORDER BY updated DESC\"}" | jq -r '.issues[] | "\(.key)\t\((.fields.summary // "") | @base64)"')

    # Fetch QA Testing tickets separately
    qa_tickets=$(curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json "{\"fields\": [\"key\",\"summary\"], \"jql\":\"assignee changed TO currentUser() ${after_clause}${before_clause:+ ${before_clause}} AND status = \\\"QA Testing\\\" AND project IN (BT, PAYM) ORDER BY updated DESC\"}" | jq -r '.issues[] | "\(.key)\t\((.fields.summary // "") | @base64)"')

    echo "  Working on ${week_label}:"
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

    echo "  Done ${week_label}:"
    # Print actual Done/Closed tickets
    curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json "{\"fields\": [\"key\",\"summary\"], \"jql\":\"assignee changed TO currentUser() ${after_clause}${before_clause:+ ${before_clause}} AND status IN (Done, Closed) AND project IN (BT, PAYM) ORDER BY updated DESC\"}" | jq -r '.issues[] | "\(.key)\t\((.fields.summary // "") | @base64)"' | print_weekly_tickets
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
