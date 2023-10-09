##!/usr/bin/awk -f

function _get_branch(designator) {
  return gensub(/(.+)@.*/, "\\1", "g", designator);
}

function _get_ticket(designator) {
  ticket_match=gensub(/[^A-Z]*([A-Z]+-[0-9]+)@.*/, "\\1", "g", designator);
  return ticket_match != designator ? ticket_match : "";
}

function capture_branch_meta(designator) {
  meta["branch"] = _get_branch(designator);
  meta["ticket"] = _get_ticket(designator);
  meta["is_ticket"] = meta["ticket"] != "";
  meta["is_deployment"] = match(meta["branch"], /master|main|release|development|staging.*|next/) != 0
}

function _get_timestamp(iso_at) {
  mktime(gsub(/[-T:]/," ", at));
  return mktime(at);
}

function _get_date(iso_at) {
  date=gensub(/T.*/, "", "g", iso_at);
  return date
}

function capture_date_meta(iso_at) {
  meta["timestamp"] = _get_timestamp(iso_at);
  meta["date"] = _get_date(iso_at);
}

{
  capture_branch_meta($5)
  capture_date_meta($3)
  at = $3;

  # for (key in meta) { print key ": " meta[key] }
  printf "{ \
    \"commit\":\"%s\", \
    \"author\":\"%s\", \
    \"at\":\"%s\", \
    \"message\":\"%s\", \
    \"designator\":\"%s\", \
    \"meta\": { \
      \"branch\":\"%s\", \
      \"date\":\"%s\", \
      \"timestamp\":\"%s\", \
      \"is_ticket\":%s, \
      \"is_deployment\":%s, \
      \"ticket\": \"%s\" \
    } \
  }\n",
  $1, $2 ,$3, $4, $5,
  meta["branch"],
  meta["date"],
  meta["timestamp"],
  meta["is_ticket"] == 1 ? "true" : "false",
  meta["is_deployment"] == 1 ? "true" : "false",
  meta["ticket"];
}
