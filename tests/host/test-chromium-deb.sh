#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
if ! command -v aarch64-linux-gnu-gcc >/dev/null || ! command -v cc >/dev/null; then
    echo 'SKIP: Chromium DEB fixture test needs native and AArch64 C compilers'
    exit 0
fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
payload="$tmp/out/chromium/payload/usr/lib/chromium-browser"
mkdir -p "$payload"
printf 'int main(void) { return 0; }\n' >"$tmp/main.c"
aarch64-linux-gnu-gcc "$tmp/main.c" -o "$payload/chrome"
CROSS_OUTPUT_DIR="$tmp/out" CHROMIUM_VERSION=126.0.6478.1 "$root/package/chromium/pack-deb.sh"
deb="$tmp/out/packages/chromium/chromium_126.0.6478.1_arm64.deb"
[[ "$(dpkg-deb -f "$deb" Architecture)" == arm64 ]]
dpkg-deb -x "$deb" "$tmp/extract"
readelf -h "$tmp/extract/usr/lib/chromium-browser/chrome" | grep -q AArch64
cc "$tmp/main.c" -o "$payload/foreign-helper"
if CROSS_OUTPUT_DIR="$tmp/out" CHROMIUM_VERSION=126.0.6478.1 "$root/package/chromium/pack-deb.sh" >"$tmp/rejected" 2>&1; then
    echo 'FAIL: foreign architecture accepted' >&2; exit 1
fi
grep -q non-AArch64 "$tmp/rejected"
echo 'Chromium DEB fixture and foreign-ELF rejection passed (not a browser build)'
