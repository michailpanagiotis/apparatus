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

if [ ! -z "$(git status --porcelain)" ]; then
  echo please commit your changes first
  exit 1
fi

ticket=$1

STATUS=$(curl -s --fail --request GET ${JIRA_API_URL}/issue/${ticket} -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" | jq -r '.fields.status.name')

if [ -z "${STATUS}" ];
then
  echo Branch is unknown to JIRA
  exit 1
fi

TRANSITION_ID=$(curl -s --request GET ${JIRA_API_URL}/issue/${ticket}/transitions -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" | jq -r '.transitions[] | select(.name=="Testing" or .name=="Begin Test") | .id')

NEXT_ASSIGNEE=$(curl --request GET "${JIRA_API_URL}/user/assignable/search?issueKey=${ticket}" -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" | jq -r '.[] | select(.displayName=="Jordan Hammond") | .accountId')

if [ -z "${TRANSITION_ID}" ];
then
  echo Issue cannot be transitioned to QA
  curl -s --request GET ${JIRA_API_URL}/issue/${ticket}/transitions -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" | jq
  exit 1
fi

if [ -z "${NEXT_ASSIGNEE}" ];
then
  echo Issue cannot be reassigned
  exit 1
fi

LOCAL_BRANCH=pmichail_${ticket}

REMOTE_BRANCH=$(git branch -a | grep "remotes/origin/${LOCAL_BRANCH}$")

if [ -z "${REMOTE_BRANCH}" ];
then
  echo Branch is unknown to Github
  exit 1
fi

git checkout staging2
git pull
git fetch origin $LOCAL_BRANCH:$LOCAL_BRANCH
git merge --no-edit $LOCAL_BRANCH
git push
git checkout master


# transition to QA
curl -s --request POST ${JIRA_API_URL}/issue/${ticket}/transitions -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json "{\"transition\":{\"id\":\"${TRANSITION_ID}\"}}"

# assign to QA user
curl -s --request PUT ${JIRA_API_URL}/issue/${ticket} -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json "{\"fields\":{\"assignee\":{\"accountId\":\"${NEXT_ASSIGNEE}\"}}}"
