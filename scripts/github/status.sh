#!/usr/bin/env bash
set -e

echo 'Github'
echo '  Requested:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:GeorgeLinardis author:willbell71 review:required' | jq -r '.items[].html_url' | sed 's/^/\t/g'

echo '  Pending:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:required' | jq -r '.items[].html_url' | sed 's/^/\t/g'

echo '  Denied:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:changes_requested' | jq -r '.items[].html_url' | sed 's/^/\t/g'

echo '  Approved:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:approved' | jq -r '.items[].html_url' | sed 's/^/\t/g'
