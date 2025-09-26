#!/usr/bin/env bash
set -e

echo 'JIRA'
echo '  My bugs:'

curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key"], "jql":"status NOT IN (Done, Closed) AND project IN (BT) AND assignee = currentUser() AND status != \"Blocked / On Hold\" ORDER BY created DESC"}' | jq -r '.issues[].key' | sed 's/^/\thttps:\/\/talentdesk.atlassian.net\/browse\//g'


echo '  My features:'
curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key"], "jql":"status NOT IN (Done, Closed) AND project IN (PAYM) AND assignee = currentUser() AND status != \"Blocked / On Hold\" ORDER BY created DESC"}' | jq -r '.issues[].key' | sed 's/^/\thttps:\/\/talentdesk.atlassian.net\/browse\//g'

if [ ! -z "${SHOW_BUGBOARD}" ];
then
    echo '  Bug board:'
    curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"fields": ["key","url","priority"], "jql":"status NOT IN (Done, Closed) AND project IN (BT) AND assignee IN (currentUser(), empty) AND type != \"New Feature\" AND status != \"Blocked / On Hold\" AND \"Team[Dropdown]\" = \"Payments development\" ORDER BY created DESC"}' |  jq -r '.issues | map({ key: .key, url: "https:\/\/talentdesk.atlassian.net\/browse\/\(.key)", priority: .fields.priority.name } | "\t\(.url) \(.priority)") []'
fi
