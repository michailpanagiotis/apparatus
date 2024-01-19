include "common";

.summary_per_ticket as $annotation_per_ticket
  | .intervals
  | map(
    .
    | (.tags | get_annotation_from_tags($annotation_per_ticket)) as $annotation
    | if $annotation == "" then empty else "timew annotate @\(.id) \"\($annotation)\"" end
  )[]
