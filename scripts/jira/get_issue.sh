#!/bin/bash

usage () {
    cat <<HELP_USAGE
Usage:
  $0 <JIRA_TICKET>
HELP_USAGE
}

if ! [ "$#" -eq 1 ]
then
    usage
    exit 1
fi

ticket=$1


curl -s --request GET ${JIRA_API_URL}/issue/${1} -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" | jq
