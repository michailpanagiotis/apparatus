include "common";

def branch_to_ticket_info:
  . | "(?<key>(?<project>[A-Z]+)-(?<number>[0-9]+)).*" as $regex
    | if test($regex) then capture($regex) else null end;

def branch_to_tags: (
  if (. | test("^(main|master|next|staging.*)$"))
  then ["Deployment"]
  else
    [(. | branch_to_ticket_info).key]
  end
);

. + input
| .tickets as $tickets
| .reflog
| map(
  .timestamp = (.timestamp | tonumber)
  | .branch = .meta.branch
)
| sort_by(.timestamp)
# group by half-hour
| group_by_change(.prev.timestamp == null or (.timestamp | quantize_down(3600)) != (.prev.timestamp | quantize_down(3600)) )
| map(
  (map(.branch) | unique) as $curr_branches
  | ($curr_branches | map(branch_to_tags) | flatten) as $curr_tags
  | ((map(.meta.ticket.id | select(. != null)) | unique) | map($tickets[.] | select(. != null))) as $curr_tickets
  | ((map(.timestamp) | get_window_of_timestamps) | .tw) as $duration
  | {
      key: $duration,
      value: {
        # records: .,
        # window: (map(.timestamp) | get_window_of_timestamps),
        tags: ($curr_tags | map(. | "\"\(.)\"")) | join(", "),
        annotation: $curr_tickets | map(.summary) | join(", "),
        tw: ("timew track " + $duration + " " + (($curr_tags | map(. | "\"\(.)\"")) | join(", ")))
      }
    }
  )
| map(.value.tw)[]
# | from_entries
