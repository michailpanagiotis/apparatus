
map(
  . as {start: $from, end: $to, tags: $tags, annotation: $annotation}
  | "from \($from) to \($to)" as $duration
  | [
    "timew track \($duration) \($tags | map("\"\(.)\"") | join(" ") )",
    if $annotation != null then "timew_annotate_by_duration \"\($duration)\" \"\($annotation)\"" else empty end
  ]
) | flatten []
