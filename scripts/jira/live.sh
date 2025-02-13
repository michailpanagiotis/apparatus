#!/bin/bash

usage () {
    cat <<HELP_USAGE
Usage:
  $0 <JIRA_TICKET>
HELP_USAGE
}

__merge_master_on() {(
  set -e
  if [ ! -z "$(git status --porcelain)" ]; then
    echo please commit your changes first
    return 1
  fi
  current=$(git branch --show-current)
  git checkout $1
  git reset --hard origin/${1}
  git pull
  git merge --no-edit master
  git push
  git checkout $current
)}

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

TRANSITION_ID=$(curl -s --request GET ${JIRA_API_URL}/issue/${ticket}/transitions -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" | jq -r '.transitions[] | select(.name=="Done") | .id')


if [ -z "${TRANSITION_ID}" ];
then
  echo Issue cannot be transitioned to Done
  exit 1
fi

LOCAL_BRANCH=pmichail_${ticket}

REMOTE_BRANCH=$(git branch -a | grep "remotes/origin/${LOCAL_BRANCH}$")

if [ -z "${REMOTE_BRANCH}" ];
then
  echo Branch is unknown to Github
  exit 1
fi

git checkout master
git pull
git fetch origin $LOCAL_BRANCH:$LOCAL_BRANCH
git merge --no-edit $LOCAL_BRANCH
git push
__merge_master_on next
__merge_master_on staging2

# transition to done
curl -s --request POST ${JIRA_API_URL}/issue/${ticket}/transitions -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json "{\"transition\":{\"id\":\"${TRANSITION_ID}\"}}"

# resolution to done
curl -s --request PUT ${JIRA_API_URL}/issue/${ticket} -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" --json "{\"fields\":{\"resolution\":{\"name\":\"Done\"}}}"
