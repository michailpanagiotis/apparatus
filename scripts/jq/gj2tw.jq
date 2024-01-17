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

def group_by_window(f): reduce .[] as $item (
  [];
  (. | last).window.quantized_end as $prev_end
  | ($item.window.quantized_start) as $curr_start
  | ($curr_start == $prev_end) as $extend
  | (if $extend then ((. | last).windows + [$item.window]) else [$item.window] end) as $windows
  | (if $extend then (((. | last) | f) + ($item | f) | unique) else ($item | f) end) as $common_values
  | ($item | .windows = $windows | f = $common_values) as $curr
  | if $extend then (.[:-1] + [$curr]) else (. + [$curr]) end
) | map(
  (.windows | map(.timestamps) | flatten | sort | unique) as $timestamps
  | .window = (.windows | merge_windows)
  | del(.windows)
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
      window: (map(.timestamp) | get_window_of_timestamps),
      tags: $curr_tags,
    }
) | group_by_window(.tags)
| map(
  "timew track " + .window.tw + " " + ((.tags | map(. | "\"\(.)\"")) | join(" "))
)[]
