split("\n")
  | map(if . == "" then empty else split("\t") end)
  | map(
    . as [$commit, $author, $at, $message, $designator]
    | {
      commit: $commit,
      author: $author,
      at: $at,
      message: $message,
      designator: $designator
    }
  )
  | map(
    . as {commit: $commit, author: $author, at: $at, message: $message, designator: $designator}
    | ($at | .[0:19] +"Z" | fromdateiso8601) as $timestamp
    | ($designator | capture("(?<branch>[^@]+)") | .branch) as $branch
    | .meta = {
        timestamp: $timestamp,
        commit: $commit,
        at: ($timestamp | todateiso8601),
        designator: $designator,
        author: $author,
        message: $message,
        branch: $branch,
        ticket: (
          $branch
          | "(?<id>(?<project>[A-Z]+)-(?<number>[0-9]+)).*" as $regex
          | if test($regex) then capture($regex) else null end
        )
      }

  )
| sort_by(.meta.timestamp)
