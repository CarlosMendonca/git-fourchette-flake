#!/usr/bin/env bash
# Appends the newest gitfourchette release to data/gitfourchette.json.
#
# gitfourchette is a Python app built from source; its runtime deps come from
# nixpkgs, so a new entry needs just one content hash (the source tree), read
# with nix-prefetch-url -- no vendorHash, no build to resolve it.
#
# Run from the repo root (so `path:.` and $PWD/data resolve correctly).
#
# Env knobs (all optional):
#   GITFOURCHETTE_DATA_DIR   where gitfourchette.json lives   (default: $PWD/data)
#   GITHUB_TOKEN             bearer token to raise the GitHub API rate limit

set -euo pipefail

DATA_DIR="${GITFOURCHETTE_DATA_DIR:-$PWD/data}"
DATA="$DATA_DIR/gitfourchette.json"
REPO="jorio/gitfourchette"

log() { printf '[gitfourchette-update] %s\n' "$*" >&2; }

gh_get() {
  local url="$1"
  local -a auth=()
  [[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
  curl -fsSL "${auth[@]}" -H "Accept: application/vnd.github+json" "$url"
}

resort() {
  local f="$1" tmp
  tmp="$(mktemp)"
  jq 'unique_by(.version) | sort_by(.version | split(".") | map(tonumber))' "$f" >"$tmp"
  mv "$tmp" "$f"
}

[[ -f "$DATA" ]] || {
  log "no data file at $DATA"
  exit 1
}

LATEST_TAG="$(gh_get "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')"
VERSION="${LATEST_TAG#v}"
log "latest upstream release: $LATEST_TAG"

if jq -e --arg v "$VERSION" 'any(.[]; .version == $v)' "$DATA" >/dev/null; then
  log "$VERSION already present, nothing to do."
  exit 0
fi

log "computing srcHash for $LATEST_TAG"
URL="https://github.com/$REPO/archive/refs/tags/${LATEST_TAG}.tar.gz"
RAW="$(nix-prefetch-url --unpack --type sha256 "$URL" 2>/dev/null)"
SRC_HASH="$(nix hash convert --hash-algo sha256 --to sri "$RAW")"
log "srcHash: $SRC_HASH"

tmp="$(mktemp)"
jq --arg v "$VERSION" --arg s "$SRC_HASH" \
  '. + [{version:$v, srcHash:$s}]' "$DATA" >"$tmp"
mv "$tmp" "$DATA"
resort "$DATA"

SAN="$(printf '%s' "$VERSION" | tr '.+-' '___')"
ATTR="gitfourchette_${SAN}"

log "verifying build of .#$ATTR"
nix build "path:.#${ATTR}"
if [[ ! -x ./result/bin/gitfourchette ]]; then
  log "ERROR: ./result/bin/gitfourchette not found or not executable"
  exit 1
fi

log "added $VERSION to $DATA ($(jq length "$DATA") entries)"
