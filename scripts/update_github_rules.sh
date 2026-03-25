#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_FILE="$ROOT_DIR/GitHub.yaml"
OUT_LIST="$ROOT_DIR/GitHub.list"
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

curl -fsSL https://api.github.com/meta | jq -r '
[
  .domains.website[],
  .domains.packages[],
  .domains.actions_inbound.full_domains[],
  .domains.actions_inbound.wildcard_domains[]
]
| map(select(length > 0))
| unique
| map(
    if startswith("*.") then {kind: "DOMAIN-SUFFIX", host: .[2:]}
    else {kind: "DOMAIN", host: .}
    end
  )
| (map(select(.kind == "DOMAIN-SUFFIX") | .host)) as $suffix_hosts
| map(
    . as $item
    | select(
        $item.kind == "DOMAIN-SUFFIX"
        or ($item.kind == "DOMAIN" and (($suffix_hosts | index($item.host)) | not))
      )
  )
| sort_by(.kind, .host)
| map("\(.kind),\(.host)")
| .[]
' > "$TMP_FILE"

{
  echo "# GitHub 域名规则（自动生成）"
  echo "# 来源: https://api.github.com/meta"
  echo "# 更新时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "payload:"
  sed 's/^/  - /' "$TMP_FILE"
} > "$OUT_FILE"

{
  echo "# GitHub 域名规则（自动生成）"
  echo "# 来源: https://api.github.com/meta"
  echo "# 更新时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  cat "$TMP_FILE"
} > "$OUT_LIST"

echo "Updated $OUT_FILE and $OUT_LIST"
