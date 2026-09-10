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
[[ "$code" -eq 64 ]] || { echo "FAIL: 'portfwd logs' with no NAME exited $code, want 64"; exit 1; }

./portfwd down | grep -q "stopped db"
sleep 1
pgrep -f "stub kubectl" >/dev/null && { echo "FAIL: kubectl still running"; exit 1; }
rm -rf "$DIR"
echo PASS
