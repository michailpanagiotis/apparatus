split("\n")
  # | map(if . == "" then empty else split("\t") end)
  | map(. | select(. != "") | [capture("(?<value>[^\t]+)(\t+|$)"; "g")] | map(.value))
  # | map(capture("(?<type>[^\t]+)\t+(?<key>[^\t]+)\t+(?<status>[^\t]+)\t+(?<priority>[^\t]+)\t+(?<created>[^\t]+)\t+(?<updated>[^\t]+)\t+(?<summary>[^\t]+)\t+"))
  | map(
    . as [$type, $key, $status, $priority, $created, $updated, $summary, $assignee]
    | {
      type: $type,
      key: $key,
      status: $status,
      priority: $priority,
      created: $created,
      summary: $summary,
      assignee: $assignee
    }
  )
  | sort_by(.meta.timestamp)
  | .[]
