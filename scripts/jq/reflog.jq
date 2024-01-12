# https://blog.differentpla.net/blog/2019/01/11/jq-reduce/
# https://stackoverflow.com/questions/30172253/cumulative-sum-in-jq

# TZ=Europe/Athens jq --slurp -f ~/.apparatus/scripts/jq/reflog.jq

def pairwise: [.[:-1], .[1:]] | transpose;

def group_by_key(f): group_by(f) | map({ key: (.[0] | (f)), value: . }) | from_entries;

def reference_siblings: [
  . as $rows
  | range(0; length) as $i
  | $rows[$i]
  | $rows[($i - 1)] as $prev_row
  | $rows[($i + 1)] as $next_row
  | .prev = (if $i == 0 then null else $rows[($i - 1)] end)
  | .next = (if $i == ($rows | length) then null else $rows[($i + 1)] end)
];

def dereference_siblings: map(del(.next) | del(.prev));

def quantize_down($step): . - . % $step;
def quantize_up($step): (. | quantize_down($step)) + $step;

def group_by_change(f): reference_siblings | [. as $rows
  | foreach range(0;length) as $i
  (
    []
    ;
      . as $acc
      | $rows[$i] as $curr_row
      | $rows[($i + 1)] as $next_row
      | (
          ($i + 1 == ($rows | length)) or ($next_row | f)
        ) as $is_last_of_group
      | {
        is_last_of_group: $is_last_of_group,
        records: (if ($i == 0) or ($curr_row | f) then [$curr_row] else $acc.records + [$curr_row] end)
      }
    ;
    if .is_last_of_group then .records else empty end
  )] | map(dereference_siblings);

def get_window_of_timestamps: . | {
  timestamps: .,
  start: min,
  end: max,
  quantized_start: min | quantize_down(1800),
  quantized_end: max | quantize_up(1800)
} | .day = (.quantized_start | strflocaltime("%Y-%m-%d"))
  | .time_start = (.quantized_start | strflocaltime("%H:%M:%S"))
  | .time_end = (.quantized_end | strflocaltime("%H:%M:%S"))
  | .iso_start = (.quantized_start | todateiso8601)
  | .iso_end = (.quantized_end | todateiso8601)
;

map(
  .timestamp = (.at | .[0:19] +"Z" | fromdateiso8601)
  | .branch = .meta.branch
)
| map(
  .timings = {
    at: (.timestamp | todateiso8601),
    effective_day: (.timestamp | strflocaltime("%Y-%m-%d")),
    time: (.timestamp | strflocaltime("%H:%M:%S"))
  }
)
| sort_by(.timestamp)
| group_by_change(.prev.timestamp == null or .timestamp - .prev.timestamp > 3600 or .branch != .prev.branch)
| map(
  first + {
    window: (map(.timestamp) | get_window_of_timestamps),
  })
# | map(.twindow = (.timestamps | get_window_of_timestamps))
#   .window = (.timestamps | {
#     start: .timestampwindow.start,
#     end: .timestampwindow.end,
#     startIso: (min as $start | (quantize_down($start) | todateiso8601)),
#     endIso: (max as $windowend | (endOfHalfHour($windowend) | todateiso8601))
#   })
# )
# | map(map(.timestamp) | [min, max])
