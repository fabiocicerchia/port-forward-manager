#!/usr/bin/env bash
# Tests the profile parser and lifecycle without a cluster (kubectl stubbed).
set -euo pipefail
SRC_DIR="$(dirname "$(realpath "$0")")"
DIR="$(mktemp -d)"
export PATH="$DIR/bin:$PATH" PORTFWD_STATE_DIR="$DIR/state" PORTFWD_RECONNECT_DELAY=1
export PORTFWD_AUDIT_LOG="$DIR/protected.log"
mkdir -p "$DIR/bin"
cat > "$DIR/bin/kubectl" <<'STUB'
#!/usr/bin/env bash
echo "stub kubectl $*"; sleep 30
STUB
chmod +x "$DIR/bin/kubectl"

fail() { echo "FAIL: $*"; exit 1; }

cd "$DIR"
cp "$SRC_DIR/portfwd" .
cat > portfwd.yaml <<'YAML'
forwards:
  - name: db
    target: svc/postgres
    namespace: data
    ports: "5432:5432"
  - name: api
    target: deploy/api
    ports: "8080:80"
YAML

./portfwd up | grep -q "2 forward(s) started"
sleep 1
grep -q "svc/postgres 5432:5432" "$PORTFWD_STATE_DIR/db.log"
grep -q -- "-n data" "$PORTFWD_STATE_DIR/db.log"
./portfwd status | grep -q "db"
code=0; ./portfwd logs 2>/dev/null || code=$?
[[ "$code" -eq 64 ]] || fail "'portfwd logs' with no NAME exited $code, want 64"

./portfwd down | grep -q "stopped db"
sleep 1
pgrep -f "stub kubectl" >/dev/null && fail "kubectl still running"

# --- portfwd env --------------------------------------------------------
cat > env.yaml <<'YAML'
forwards:
  - name: db
    target: svc/postgres
    ports: "5432:5432"
  - name: api-gw
    target: deploy/api
    ports: "8080:80"
YAML

out="$(./portfwd env env.yaml)"
[[ "$out" == "DB_HOST=localhost
DB_PORT=5432
API_GW_HOST=localhost
API_GW_PORT=8080" ]] || fail "dotenv output was:
$out"

out="$(./portfwd env env.yaml --format export)"
grep -qx "export DB_PORT=5432" <<<"$out" || fail "export format was:
$out"
# The dash in api-gw has to become an underscore or the line is not sourceable.
grep -qx "export API_GW_HOST=localhost" <<<"$out" \
  || fail "export format did not sanitise the key for api-gw:
$out"

json="$(./portfwd env env.yaml --format json)"
[[ "$json" == '{
  "DB_HOST": "localhost",
  "DB_PORT": "5432",
  "API_GW_HOST": "localhost",
  "API_GW_PORT": "8080"
}' ]] || fail "json output was:
$json"
command -v python3 >/dev/null && python3 -c 'import json,sys; json.load(sys.stdin)' <<<"$json"

code=0; ./portfwd env env.yaml --format yaml 2>/dev/null || code=$?
[[ "$code" -eq 64 ]] || fail "'portfwd env --format yaml' exited $code, want 64"

# --- protected forwards -------------------------------------------------
cat > prod.yaml <<'YAML'
contexts:
  - name: prod
    protected: true
forwards:
  - name: dev-db
    target: svc/postgres
    namespace: data
    ports: "5432:5432"
  - name: prod-db
    target: svc/postgres
    namespace: data
    ports: "15432:5432"
    context: prod
  - name: payments
    target: svc/payments
    ports: "9000:80"
    protected: true
YAML

# Protected by context and protected per-forward both need a reason, and
# nothing starts until one is given.
code=0; out="$(./portfwd up prod.yaml 2>&1)" || code=$?
[[ "$code" -eq 77 ]] || fail "'portfwd up' on a protected profile exited $code, want 77"
grep -q "prod-db" <<<"$out" || fail "refusal did not name prod-db (protected by context)"
grep -q "payments" <<<"$out" || fail "refusal did not name payments (protected per-forward)"
[[ -e "$PORTFWD_STATE_DIR/dev-db.want" ]] && fail "refusal still started dev-db"
[[ -e "$PORTFWD_AUDIT_LOG" ]] && fail "a refused run was written to the log"

./portfwd up prod.yaml --reason "incident 4711" | grep -q "3 forward(s) started"
sleep 1
out="$(./portfwd status)"
grep -q "prod-db.*\[protected\]" <<<"$out" || fail "status does not mark prod-db protected:
$out"
grep -q "dev-db" <<<"$out" || fail "status lost dev-db"
grep -q "dev-db.*\[protected\]" <<<"$out" && fail "dev-db marked protected"

./portfwd down >/dev/null
sleep 1
[[ -f "$PORTFWD_AUDIT_LOG" ]] || fail "no protected-session log at $PORTFWD_AUDIT_LOG"
[[ "$(wc -l < "$PORTFWD_AUDIT_LOG")" -eq 2 ]] \
  || fail "want one log line per protected session, got: $(cat "$PORTFWD_AUDIT_LOG")"
# context, namespace, target, user, start, end, reason — tab separated.
line="$(grep 'svc/postgres' "$PORTFWD_AUDIT_LOG")"
IFS=$'\t' read -r l_ctx l_ns l_target l_user l_start l_end l_reason <<<"$line"
[[ "$l_ctx" == "prod" ]]        || fail "log context was '$l_ctx'"
[[ "$l_ns" == "data" ]]         || fail "log namespace was '$l_ns'"
[[ "$l_target" == "svc/postgres" ]] || fail "log target was '$l_target'"
[[ "$l_user" == "${USER:-$(id -un)}" ]] || fail "log user was '$l_user'"
[[ "$l_start" == 20??-??-??T??:??:??Z ]] || fail "log start was '$l_start'"
[[ "$l_end" == 20??-??-??T??:??:??Z ]]   || fail "log end was '$l_end'"
[[ "$l_reason" == "incident 4711" ]]     || fail "log reason was '$l_reason'"
grep -q "svc/payments" "$PORTFWD_AUDIT_LOG" || fail "per-forward protected session not logged"
# The log holds who reached prod and why; nobody else needs to read it.
[[ "$(stat -c %a "$PORTFWD_AUDIT_LOG" 2>/dev/null || stat -f %Lp "$PORTFWD_AUDIT_LOG")" == "600" ]] \
  || fail "protected-session log is not mode 600"

# A supervisor killed with the machine still leaves a closed record behind.
./portfwd up prod.yaml --reason "after hours" >/dev/null
sleep 1
for pid in "$PORTFWD_STATE_DIR"/*.pid; do kill -9 "$(cat "$pid")" 2>/dev/null || true; done
rm -f "$PORTFWD_STATE_DIR"/*.pid
./portfwd up prod.yaml --reason "back again" >/dev/null
grep -q "interrupted.*after hours" "$PORTFWD_AUDIT_LOG" \
  || fail "an interrupted protected session was not closed out"
./portfwd down >/dev/null
sleep 1

rm -rf "$DIR"
echo PASS
