# https://blog.differentpla.net/blog/2019/01/11/jq-reduce/
# https://stackoverflow.com/questions/30172253/cumulative-sum-in-jq

# TZ=Europe/Athens jq --slurp -f ~/.apparatus/scripts/jq/reflog.jq

def pairwise: [.[:-1], .[1:]] | transpose;

def group_by_key(f): group_by(f) | map({ key: (.[0] | (f)), value: . }) | from_entries;

def belong_to_different_groups($from; $to): $from.branch != $to.branch;
def have_different_branch($from; $to): $from.branch != $to.branch;

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



def sequential_group_by: [. as $rows
  | foreach range(0;length) as $i
  (
    []
    ;
      . as $acc
      | ($rows | length) as $total
      | $rows[$i] as $curr_row
      | $rows[($i - 1)] as $prev_row
      | $rows[($i + 1)] as $next_row
      | (
          ($i == 0) or belong_to_different_groups($prev_row; $curr_row)
        ) as $is_first_of_group
      | (
          ($i + 1 == $total) or belong_to_different_groups($curr_row; $next_row)
        ) as $is_last_of_group
      | {
        is_last_of_group: $is_last_of_group,
        records: (if $is_first_of_group then [$curr_row] else $acc.records + [$curr_row] end)
      }
    ;
    . as $acc
    | if .is_last_of_group then .records else empty end
  )];

map({
    branch: .meta.branch,
    timestamp: (.at | .[0:19] +"Z" | fromdateiso8601),
    effective_day: (.at | .[0:19] +"Z" | fromdateiso8601 | strftime("%Y-%m-%d")),
    at: .at,
    time: (.at | .[0:19] +"Z" | fromdateiso8601 | strflocaltime("%H:%M:%S"))
})
| sort_by(.timestamp)
| reference_siblings
| map(.changed_branch = (.branch != .prev.branch) | .started_session = (.prev.timestamp == null or .timestamp - .prev.timestamp > 3600))
| dereference_siblings
# | .changed_branch = (.branch != .prev.branch)
# | map(. as [$from, $to] | $to | .changed_branch = have_different_branch($from; $to))
# | length

# map({
#     branch: .meta.branch,
#     timestamp: (.at | .[0:19] +"Z" | fromdateiso8601),
#     effective_day: (.at | .[0:19] +"Z" | fromdateiso8601 | strftime("%Y-%m-%d")),
#     at: .at,
#     time: (.at | .[0:19] +"Z" | fromdateiso8601 | strflocaltime("%H:%M:%S"))
# })
# | sort_by(.timestamp)
# | group_by_key(.effective_day)
# | map_values(
#     sequential_group_by | map({ branch: first.branch, timestamps: map(.timestamp) })
#   )
