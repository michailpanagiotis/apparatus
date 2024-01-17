include "common";

def branch_to_ticket_info:
  . | "(?<key>(?<project>[A-Z]+)-(?<number>[0-9]+)).*" as $regex
    | if test($regex) then capture($regex) else null end;

def branch_to_tags: (
  if (. | test("^(main|master|next|staging.*)$"))
  then ["auto", "Deployment"]
  else
    ["auto", (. | branch_to_ticket_info).key]
  end
);

def merge_windows: reduce .[] as $item (
  [];
  (. | last).value.window.quantized_end as $prev_end
  | ($item.value.window.quantized_start) as $curr_start
  | ($curr_start == $prev_end) as $extend
  | ($item | .extend = $extend) as $curr
  | . + [$curr]
);

.
| map(
  .timestamp = (.timestamp | tonumber)
  | .branch = .meta.branch
)
| sort_by(.timestamp)
# group by half-hour
| group_by_change(.prev.timestamp == null or (.timestamp | quantize_down(3600)) != (.prev.timestamp | quantize_down(3600)) )
| map(
  (map(.branch) | unique) as $curr_branches
  | ($curr_branches | map(branch_to_tags) | flatten | unique | sort_by(. | ascii_downcase)) as $curr_tags
  | ((map(.timestamp) | get_window_of_timestamps) | .tw) as $duration
  | {
      key: $duration,
      value: {
        # records: .,
        window: (map(.timestamp) | get_window_of_timestamps),
        tags: ($curr_tags | map(. | "\"\(.)\"")) | join(", "),
        tw: ($duration + " " + (($curr_tags | map(. | "\"\(.)\"")) | join(" ")))
      }
    }
) | merge_windows
# | map(.value.tw)[]
