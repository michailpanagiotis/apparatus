include "common";

.tickets as $tickets
  | .intervals
  | map(
    .
    | (.tags | get_tickets_from_tags | map($tickets[.].summary) | join(", ")) as $annotation
    | if $annotation == "" then empty else "timew annotate @\(.id) \"\($annotation)\"" end
  )[]
