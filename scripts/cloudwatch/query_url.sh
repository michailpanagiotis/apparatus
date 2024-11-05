#!/bin/bash
set -e

if [[ -z "$1" ]]; then
  echo "Please provide file with query"
  exit -1
fi

if ! [[ -f "$1" ]]; then
  echo "$1 is not a file"
  exit -1
fi

if [[ -z "${PROFILE}" ]]; then
  echo "Env variable PROFILE is required"
  exit -1
fi

if [[ -z "${START_TIME}" ]]; then
  echo "Env variable START_TIME (ISO 8601) is required"
  exit -1
fi

START_TIMESTAMP=$(gdate -d "${START_TIME}" "+%s")

if [[ -z "${END_TIME}" ]]; then
  echo "Env variable END_TIME (ISO 8601) is required"
  exit -1
fi

END_TIMESTAMP=$(gdate -d "${END_TIME}" "+%s")

if [[ -z "${LOG_GROUP}" ]]; then
  echo "Env variable LOG_GROUP is required"
  exit -1
fi

EXPRESSION=$(cat $1)

echo "
Query:

$EXPRESSION
"

REGION=$(aws configure --profile $PROFILE get region)

query_id=$(aws logs start-query --profile $PROFILE --log-group-name $LOG_GROUP \
 --region $REGION \
 --start-time $START_TIMESTAMP --end-time $END_TIMESTAMP \
 --query-string "$EXPRESSION" \
 | jq -r '.queryId')

SCRIPT="
  const JSURL = require('jsurl');
  const query = {
    end: '$END_TIME',
    start: '$START_TIME',
    editorString: \`${EXPRESSION}\`,
    source: ['$LOG_GROUP'],
    timeType: 'ABSOLUTE',
    queryId: '$query_id',
  };
  console.log(\`https://$REGION.console.aws.amazon.com/cloudwatch/home?region=$REGION#logsV2:logs-insights?queryDetail=\${JSURL.stringify(query)}\`)
"
node -e "$SCRIPT"

# while [ "$(aws logs describe-queries --profile $PROFILE --log-group-name $LOG_GROUP | jq -r ".queries[] | select(.queryId==\"$query_id\") | .status")" = "Running" ]
# do
#   echo Waiting for query to complete...
#   sleep 2
# done
# aws --profile $PROFILE logs get-query-results --query-id $query_id
