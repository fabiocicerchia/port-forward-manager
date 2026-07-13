#!/usr/bin/env bash
# Tests the profile parser and lifecycle without a cluster (kubectl stubbed).
set -euo pipefail
SRC_DIR="$(dirname "$(realpath "$0")")"
DIR="$(mktemp -d)"
export PATH="$DIR/bin:$PATH" PFM_STATE_DIR="$DIR/state" PFM_RECONNECT_DELAY=1
mkdir -p "$DIR/bin"
cat > "$DIR/bin/kubectl" <<'STUB'
#!/usr/bin/env bash
echo "stub kubectl $*"; sleep 30
STUB
chmod +x "$DIR/bin/kubectl"

cd "$DIR"
cp "$SRC_DIR/pfm" .
cat > pfm.yaml <<'YAML'
forwards:
  - name: db
    target: svc/postgres
    namespace: data
    ports: "5432:5432"
  - name: api
    target: deploy/api
    ports: "8080:80"
YAML

./pfm up | grep -q "2 forward(s) started"
sleep 1
grep -q "svc/postgres 5432:5432" "$PFM_STATE_DIR/db.log"
grep -q -- "-n data" "$PFM_STATE_DIR/db.log"
./pfm status | grep -q "db"
./pfm down | grep -q "stopped db"
sleep 1
pgrep -f "stub kubectl" >/dev/null && { echo "FAIL: kubectl still running"; exit 1; }
rm -rf "$DIR"
echo PASS
