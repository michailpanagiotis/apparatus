
include "common";

[inputs]
  | map(select(test("{")))
  | join("") | "[" + . + "]"
  | fromjson
  | map(
    (.start | strptime("%Y%m%dT%H%M%SZ") | mktime) as $start_timestamp
    | (.end | strptime("%Y%m%dT%H%M%SZ") | mktime) as $end_timestamp
    | .meta={
      window: ([$start_timestamp, $end_timestamp] | get_quantized_window_of_timestamps),
      tickets: (.tags | get_tickets_from_tags)
    }
  )
