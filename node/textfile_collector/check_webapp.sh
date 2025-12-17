#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${OUT_DIR:-/var/lib/node_exporter/textfile_collector}"
URL="${WEBAPP_URL:-http://127.0.0.1:8080/health}"
OUT_FILE="${OUT_DIR}/webapp.prom"

mkdir -p "$OUT_DIR"

tmp="$(mktemp)"
start_ns="$(date +%s%N)"

if curl -fsS --max-time 2 "$URL" >/dev/null 2>&1; then
  up=1
else
  up=0
fi

end_ns="$(date +%s%N)"
# response time seconds (rough)
rt="$(python3 - <<PY
s=${start_ns}
e=${end_ns}
print((e-s)/1e9)
PY
)"

{
  echo "# HELP webapp_up Web application healthcheck (1=up, 0=down)"
  echo "# TYPE webapp_up gauge"
  echo "webapp_up{url=\"${URL}\"} ${up}"
  echo "# HELP webapp_response_time_seconds Webapp healthcheck response time in seconds"
  echo "# TYPE webapp_response_time_seconds gauge"
  echo "webapp_response_time_seconds{url=\"${URL}\"} ${rt}"
} > "$tmp"

# atomic replace
mv "$tmp" "$OUT_FILE"
