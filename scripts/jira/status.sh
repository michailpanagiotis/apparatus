#!/usr/bin/env bash
set -e

echo 'JIRA'
echo '  My bugs:'
curl -s --request POST ${JIRA_API_URL}/search -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"jql":"status NOT IN (Done, Closed) AND project IN (BT) AND assignee = currentUser() AND status != \"Blocked / On Hold\" ORDER BY created DESC"}' | jq -r '.issues[].key' | sed 's/^/\thttps:\/\/talentdesk.atlassian.net\/browse\//g'

echo '  My features:'
curl -s --request POST ${JIRA_API_URL}/search -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"jql":"status NOT IN (Done, Closed) AND project IN (PAYM) AND assignee = currentUser() AND status != \"Blocked / On Hold\" ORDER BY created DESC"}' | jq -r '.issues[].key' | sed 's/^/\thttps:\/\/talentdesk.atlassian.net\/browse\//g'

if [ ! -z "${SHOW_BUGBOARD}" ];
then
    echo '  Bug board:'
    curl -s --request POST ${JIRA_API_URL}/search -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json '{"jql":"status NOT IN (Done, Closed) AND project IN (BT) AND assignee IN (currentUser(), empty) AND status != \"Blocked / On Hold\" AND \"Team[Dropdown]\" = \"Payments development\" ORDER BY created DESC"}' | jq -r '.issues[].key' | sed 's/^/\thttps:\/\/talentdesk.atlassian.net\/browse\//g'
fi
