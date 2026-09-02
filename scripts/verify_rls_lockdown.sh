#!/usr/bin/env bash
# AM-22 — Confirm public INSERT is blocked by RLS (not by a schema/constraint error).
# Uses the anon key only (same privilege as an unsigned-in client).
#
# PASS: HTTP 401 or 403 AND response body contains "row-level security policy"
# FAIL: HTTP 200/201 (write went through)
# INCONCLUSIVE: anything else (400 schema error, 402 quota, 409 unique, 5xx, network)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "FAIL: $ENV_FILE not found"
  exit 1
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  case "$line" in
    SUPABASE_URL=*|SUPABASE_ANON_KEY=*)
      eval "$line"
      ;;
  esac
done < "$ENV_FILE"

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "FAIL: SUPABASE_URL / SUPABASE_ANON_KEY missing from .env"
  exit 1
fi

AUTH_H=(
  -H "apikey: $SUPABASE_ANON_KEY"
  -H "Authorization: Bearer $SUPABASE_ANON_KEY"
  -H "Content-Type: application/json"
)

rest_get() {
  local path="$1"
  local body_file="$2"
  curl -sS -o "$body_file" -w "%{http_code}" \
    "$SUPABASE_URL/rest/v1/$path" \
    "${AUTH_H[@]}"
}

rest_post() {
  local table="$1"
  local payload="$2"
  local body_file="$3"
  curl -sS -o "$body_file" -w "%{http_code}" \
    -X POST "$SUPABASE_URL/rest/v1/$table" \
    "${AUTH_H[@]}" \
    -H "Prefer: return=minimal" \
    -d "$payload"
}

print_body() {
  local label="$1"
  local file="$2"
  echo "----- $label body -----"
  cat "$file"
  echo
  echo "----- end $label body -----"
}

judge() {
  local table="$1"
  local code="$2"
  local body_file="$3"
  local body
  body="$(cat "$body_file")"
  local body_lc
  body_lc="$(printf '%s' "$body" | tr '[:upper:]' '[:lower:]')"

  echo "anon INSERT $table → HTTP $code"

  if [[ "$code" == "200" || "$code" == "201" ]]; then
    echo "FAIL: anon insert into $table succeeded. RLS lockdown is NOT live."
    return 2
  fi

  if [[ "$code" == "401" || "$code" == "403" ]]; then
    if [[ "$body_lc" == *"row-level security policy"* ]]; then
      echo "PASS: $table rejected by RLS (HTTP $code, policy wording present)."
      return 0
    fi
    echo "INCONCLUSIVE: $table HTTP $code but body does not mention row-level security policy."
    return 1
  fi

  echo "INCONCLUSIVE: $table HTTP $code is not an RLS rejection (need 401/403 + policy wording)."
  return 1
}

verses_get_file=/tmp/am22_verses_select.body
parvas_get_file=/tmp/am22_parvas_select.body
verses_post_file=/tmp/am22_verses.body
parvas_post_file=/tmp/am22_parvas.body

echo "== public SELECT (sanity) =="
verses_get_code="$(rest_get "verses?select=id,book_id,chapter_id&limit=1" "$verses_get_file")"
parvas_get_code="$(rest_get "parvas?select=id,name&limit=1" "$parvas_get_file")"
echo "anon SELECT verses → HTTP $verses_get_code"
print_body "verses SELECT" "$verses_get_file"
echo "anon SELECT parvas → HTTP $parvas_get_code"
print_body "parvas SELECT" "$parvas_get_file"

if [[ "$verses_get_code" != "200" ]]; then
  echo "INCONCLUSIVE: cannot read verses (HTTP $verses_get_code); insert probe would not be schema-valid."
  exit 1
fi

fk="$(python3 - "$verses_get_file" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
if not isinstance(data, list) or not data:
    sys.exit(2)
row = data[0]
book = row.get("book_id")
chapter = row.get("chapter_id")
if not book or not chapter:
    sys.exit(2)
print(f"{book}\t{chapter}")
PY
)" || {
  echo "INCONCLUSIVE: verses SELECT returned no book_id/chapter_id pair to reuse as a real FK."
  exit 1
}

book_id="${fk%%	*}"
chapter_id="${fk#*	}"
echo "Using live FK pair book_id=$book_id chapter_id=$chapter_id"

verses_payload="$(python3 -c "import json,sys; print(json.dumps({
  'id': '__rls_probe__',
  'book_id': sys.argv[1],
  'chapter_id': sys.argv[2],
  'verse_number': 999999,
  'verse_number_display': '__rls_probe__',
  'order_index': 999999
}))" "$book_id" "$chapter_id")"

parvas_payload='{"id":-999999,"name":"__rls_probe__","subtitle":"__rls_probe__","status":"locked"}'

echo
echo "== public INSERT probes (schema-valid) =="
verses_code="$(rest_post verses "$verses_payload" "$verses_post_file")"
print_body "verses INSERT" "$verses_post_file"
parvas_code="$(rest_post parvas "$parvas_payload" "$parvas_post_file")"
print_body "parvas INSERT" "$parvas_post_file"

exit_code=0
judge verses "$verses_code" "$verses_post_file" || {
  rc=$?
  if [[ $rc -gt $exit_code ]]; then exit_code=$rc; fi
}
judge parvas "$parvas_code" "$parvas_post_file" || {
  rc=$?
  if [[ $rc -gt $exit_code ]]; then exit_code=$rc; fi
}

# If a probe row actually landed, try to delete it so we don't leave junk.
if [[ "$verses_code" == "201" || "$verses_code" == "200" ]]; then
  curl -sS -o /dev/null -X DELETE \
    "$SUPABASE_URL/rest/v1/verses?id=eq.__rls_probe__" \
    "${AUTH_H[@]}" || true
fi
if [[ "$parvas_code" == "201" || "$parvas_code" == "200" ]]; then
  curl -sS -o /dev/null -X DELETE \
    "$SUPABASE_URL/rest/v1/parvas?id=eq.-999999" \
    "${AUTH_H[@]}" || true
fi

if [[ "$exit_code" -eq 0 ]]; then
  echo "AM-22 verification passed: both inserts were rejected by RLS."
  exit 0
fi
if [[ "$exit_code" -eq 2 ]]; then
  echo "AM-22 verification FAILED: at least one public write succeeded."
  exit 2
fi
echo "AM-22 verification INCONCLUSIVE: could not prove RLS from the responses above."
exit 1
