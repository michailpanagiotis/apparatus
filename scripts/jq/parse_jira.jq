split("\n")
  | map(if . == "" then empty else split("\t") end)
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
