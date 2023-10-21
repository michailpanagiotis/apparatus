##!/usr/bin/awk -f
{
  printf "{ \
    \"type\":\"%s\", \
    \"key\":\"%s\", \
    \"status\":\"%s\", \
    \"priority\":\"%s\", \
    \"created\":\"%s\", \
    \"updated\":\"%s\", \
    \"summary\":\"%s\", \
    \"assignee\":\"%s\" \
  }\n",
  $1, $2 ,$3, $4, $5, $6, $7, $8
}
