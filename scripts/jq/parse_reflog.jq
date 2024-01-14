split("\n")
  | map(if . == "" then empty else split("\t") end)
  | map(
    . as [$commit, $author, $timestamp, $message, $designator]
    | {
      commit: $commit,
      author: $author,
      timestamp: ($timestamp | tonumber),
      message: $message,
      designator: $designator
    }
  )
  | map(
    . as {commit: $commit, author: $author, timestamp: $timestamp, message: $message, designator: $designator}
    | ($designator | capture("(?<branch>[^@]+)") | .branch) as $branch
    | .meta = {
        at: ($timestamp | todateiso8601),
        branch: $branch,
        ticket: (
          $branch
          | "(?<id>(?<project>[A-Z]+)-(?<number>[0-9]+)).*" as $regex
          | if test($regex) then capture($regex) else null end
        )
      }

  )
| sort_by(.meta.timestamp)
