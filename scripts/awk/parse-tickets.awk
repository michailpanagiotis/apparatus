##!/usr/bin/awk -f

function _get_ticket_project(ticket) {
  number_start_idx = match(ticket, /[0-9]+/);
  ticket_project = substr(ticket, 0, number_start_idx - 2);
  return ticket_project;
}

function print_last_project() {
  if (last_project != "") {
    printf("%s ", last_project);
    for (t = 1; t < curr_ticket_idx; t++) {
      if (t == 1) {
        printf("%s", curr_tickets[t]);
      } else {
        printf(",%s", curr_tickets[t]);
      }
    }
    printf("\n");
  }
}

{
  split($0,tickets," ")
  n = asort(tickets)
  last_project = "";
  for (x = 1; x <= n; x++) {
    # printf("CHECKING %s --> %s\n", x, tickets[x]);
    project = _get_ticket_project(tickets[x]);
    if (last_project != project) {
      print_last_project();
      curr_ticket_idx = 1;
      last_project = project;
    }

    # printf("SETTING %s to %s\n", curr_ticket_idx, tickets[x]);
    curr_tickets[curr_ticket_idx] = tickets[x];
    curr_ticket_idx = curr_ticket_idx + 1;
  }
  print_last_project();
}
