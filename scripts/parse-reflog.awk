##!/usr/bin/awk -f

  function last_bound(t, s) {
    timestamp=mktime(t);
    last=timestamp - timestamp % s;
    return strftime("%Y%m%dT%H%M%S", last);
  }

  function next_bound(t, s){
    timestamp=mktime(t);
    expected_next = timestamp + s
    end=expected_next - expected_next % s
    return strftime("%Y%m%dT%H%M%S", end);
  }

  { \
  meta[branch]=gensub(/(.+)@.*/, "\\1", "g", $5);
  regex=/[^A-Z]*([A-Z]+-[0-9]+)@.*/;
  ticket_match=gensub(/[^A-Z]*([A-Z]+-[0-9]+)@.*/, "\\1", "g", $5);
  ticket = ticket_match != $5 ? ticket_match : "";
  day=gensub(/T.*/, "", "g", $3);
  at = $3;
  mktime(gsub(/[-T:]/," ", at));
  timestamp=mktime(at);
  if (branch == "master") {
      tw_start=last_bound(at, 3600);
      tw_end=next_bound(at, 3600);
  } else {
      tw_start=last_bound(at, 1800);
      tw_end=next_bound(at, 1800);
  }
  printf \
"{ \
\"commit\":\"%s\", \
\"author\":\"%s\", \
\"at\":\"%s\", \
\"message\":\"%s\", \
\"designator\":\"%s\", \
\"branch\":\"%s\", \
\"day\":\"%s\", \
\"tw_start\":\"%s\", \
\"tw_end\":\"%s\", \
\"ticket\": \"%s\" \
}\n", $1, $2 ,$3, $4, $5, meta[branch], day, tw_start, tw_end, ticket}
