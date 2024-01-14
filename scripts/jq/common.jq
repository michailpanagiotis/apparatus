# https://blog.differentpla.net/blog/2019/01/11/jq-reduce/
# https://stackoverflow.com/questions/30172253/cumulative-sum-in-jq

# TZ=Europe/Athens jq --slurp -f ~/.apparatus/scripts/jq/reflog.jq

def pairwise: [.[:-1], .[1:]] | transpose;

# GROUPING FUNCTIONS

def group_by_key(f): group_by(f) | map({ key: (.[0] | (f)), value: . }) | from_entries;

def __reference_siblings: [
  . as $rows
  | range(0; length) as $i
  | $rows[$i]
  | $rows[($i - 1)] as $prev_row
  | $rows[($i + 1)] as $next_row
  | .prev = (if $i == 0 then null else $rows[($i - 1)] end)
  | .next = (if $i == ($rows | length) then null else $rows[($i + 1)] end)
];

def __dereference_siblings: map(del(.next) | del(.prev));

def group_by_change(f): __reference_siblings | [. as $rows
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
  )] | map(__dereference_siblings);


# TIMESTAMP WINDOW FUNCTIONS

def quantize_down($step): . - . % $step;
def quantize_up($step): (. | quantize_down($step)) + $step;

def get_window_of_timestamps: . | {
  timestamps: .,
  start: min,
  end: max,
  quantized_start: min | quantize_down(1800),
  quantized_end: max | quantize_up(1800)
} | .iso_start = (.quantized_start | todateiso8601)
  | .iso_end = (.quantized_end | todateiso8601)
  | .day = (.quantized_start | strflocaltime("%Y-%m-%d"))
  | .time = (.quantized_start | strflocaltime("%H:%M")) + "-" + (.quantized_end | strflocaltime("%H:%M"))
  | .tw = "from " + (.quantized_start | strflocaltime("%Y%m%dT%H%M")) + " to " + (.quantized_end | strflocaltime("%Y%m%dT%H%M"))
;
