##!/usr/bin/awk -f

function join(array, start, end, sep,    result, i)
{
  if (sep == "")
    sep = " "
  else if (sep == SUBSEP) # magic value
    sep = ""
  result = array[start]
  for (i = start + 1; i <= end; i++)
    result = result sep array[i]
  return result
}

function _get_ticket_project(ticket) {
  number_start_idx = match(ticket, /[0-9]+/);
  ticket_project = substr(ticket, 0, number_start_idx - 2);
  return ticket_project;
}

{
  split($0,tickets," ")
  n = asort(tickets)
  last_project = "";
  for (x = 1; x <= n; x++) {
    # printf("CHECKING %s --> %s\n", x, tickets[x]);
    project = _get_ticket_project(tickets[x]);
    if (last_project != project) {
      if (last_project) {
        printf("%s %s\n", last_project, join(curr_tickets, 1, curr_ticket_idx - 1, ","));
      }
      curr_ticket_idx = 1;
      last_project = project;
    }

    # printf("SETTING %s to %s\n", curr_ticket_idx, tickets[x]);
    curr_tickets[curr_ticket_idx] = tickets[x];
    curr_ticket_idx = curr_ticket_idx + 1;
  }

  if (last_project) {
    printf("%s %s\n", last_project, join(curr_tickets, 1, curr_ticket_idx - 1, ","));
  }
}
