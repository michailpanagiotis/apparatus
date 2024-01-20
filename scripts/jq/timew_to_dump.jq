
.intervals
| map(
  . as {start: $from, end: $to, tags: $tags, annotation: $annotation}
  | "from \($from) to \($to)" as $duration
  | [
    "timew track \($duration) \($tags | map("\"\(.)\"") | join(" ") )",
    if $annotation != null then "timew annotate_by_range \($duration) \"\($annotation)\"" else empty end
  ]
) | flatten []
