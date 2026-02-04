#!/usr/bin/env bash
set -e

# Load QA tickets from github script
qa_tickets_file="/tmp/qa_jira_tickets"

print_ticket_with_qa_marker() {
  while read -r key; do
    url="https://talentdesk.atlassian.net/browse/${key}"
    if [[ -f "$qa_tickets_file" ]] && grep -qx "$key" "$qa_tickets_file" 2>/dev/null; then
      printf '\t%s [QA]\n' "$url"
    else
      printf '\t%s\n' "$url"
    fi
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
    curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key","url","priority"], "jql":"status NOT IN (Done, Closed) AND project IN (BT) AND assignee IN (currentUser(), empty) AND type != \"New Feature\" AND status != \"Blocked / On Hold\" AND \"Team[Dropdown]\" = \"Payments development\" ORDER BY created DESC"}' |  jq -r '.issues | map({ key: .key, url: "https:\/\/talentdesk.atlassian.net\/browse\/\(.key)", priority: .fields.priority.name } | "\t\(.url) \(.priority)") []'
fi
