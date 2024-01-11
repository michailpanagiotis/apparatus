# https://blog.differentpla.net/blog/2019/01/11/jq-reduce/
# https://stackoverflow.com/questions/30172253/cumulative-sum-in-jq


def group_by_key(f): group_by(f) | map({ key: (.[0] | f), value: . }) | from_entries;

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
| . as $rows | foreach range(0;length) as $i
  (
    {}
    ;
      ($rows[$i].branch != .branch) as $changed_branch
      | $rows[$i] as $curr_row
      | (
          # is first row
          ($i == 0)
          # branch has changed
          or ($rows[($i + -1)].branch != $curr_row.branch)
        ) as $is_first_for_branch
      | .is_first_for_branch = $is_first_for_branch
      | .is_last_for_branch = (
          # is last row
          ($i + 1 == ($rows | length))
          # branch will change
          or ($rows[($i + 1)].branch != $curr_row.branch)
        )
      | .timings = if $is_first_for_branch then [$curr_row] else .timings + [$curr_row] end
    ; . as $curr
      | $rows[$i] as $curr_row
      | $curr_row
      | if $curr.is_last_for_branch then .curr = $curr else empty end
  )
