# https://blog.differentpla.net/blog/2019/01/11/jq-reduce/
# https://stackoverflow.com/questions/30172253/cumulative-sum-in-jq


def group_by_key(f): group_by(f) | map({ key: (.[0] | f), value: . }) | from_entries;

def group_subsequent(f): [. as $rows | foreach range(0;length) as $i
  (
    []
    ;
      . as $acc
      | $rows[$i] as $curr_row
      | (
          # is first row
          ($i == 0)
          # group has changed
          or (($rows[($i + -1)] | f) != ($curr_row | f))
        ) as $is_first_of_group
      | (
          # is last row
          ($i + 1 == ($rows | length))
          # group will change
          or (($rows[($i + 1)] | f ) != ($curr_row | f))
        ) as $is_last_of_group
      | {
        is_first_of_group: $is_first_of_group,
        is_last_of_group: $is_last_of_group,
        records: (if $is_first_of_group then [$curr_row] else $acc.records + [$curr_row] end)
      }
    ; . as $acc
      | $rows[$i] as $curr_row
      | $curr_row
      | if $acc.is_last_of_group then { key: ($curr_row | f), value: $acc.records } else empty end
  )];

map({
    branch: .meta.branch,
    at: .at,
    timestamp: (.at | .[0:19] +"Z" | fromdateiso8601),
    effective_day: (.at | .[0:19] +"Z" | fromdateiso8601 | strftime("%Y-%m-%d"))
})
# sort
| sort_by(.at)
# | group_by_key(.effective_day)
# merge sequential commits to same branch
| group_subsequent(.branch)
