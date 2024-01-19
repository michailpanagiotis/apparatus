
include "common";

map(.tags)
  | flatten
  | get_tickets_from_tags
  | join(" ")
