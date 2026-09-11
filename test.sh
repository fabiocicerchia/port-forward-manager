#!/usr/bin/env bash
# Tests the profile parser and lifecycle without a cluster (kubectl stubbed).
set -euo pipefail
SRC_DIR="$(dirname "$(realpath "$0")")"
DIR="$(mktemp -d)"
export PATH="$DIR/bin:$PATH" PORTFWD_STATE_DIR="$DIR/state" PORTFWD_RECONNECT_DELAY=1
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

rm -rf "$DIR"
echo PASS
