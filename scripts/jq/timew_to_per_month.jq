include "common";

def categorize_interval:
  .tags | map(select(. != "Bespot" and . != "auto"));

.
| map(.category = (. | categorize_interval))

# | group_by(.meta.window.month)
# | map({
#   key: (first | .meta.window.month),
#   value: {
#     start: (map(.meta.window.quantized_start) | min),
#     hours: ((map(.meta.window.minute_duration) | add) / 60),
#     intervals: .
#   }
# })
# | from_entries
