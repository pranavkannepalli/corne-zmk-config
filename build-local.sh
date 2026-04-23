#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

export PATH="/opt/homebrew/bin:${PATH}"
export ZEPHYR_SDK_INSTALL_DIR="${ZEPHYR_SDK_INSTALL_DIR:-$HOME/zephyr-sdk-0.16.9}"

if ! command -v cmake >/dev/null 2>&1; then
  echo "cmake not found. Install with: brew install cmake ninja dtc" >&2
  exit 1
fi

if ! command -v ninja >/dev/null 2>&1; then
  echo "ninja not found. Install with: brew install ninja" >&2
  exit 1
fi

if ! command -v dtc >/dev/null 2>&1; then
  echo "dtc not found. Install with: brew install dtc" >&2
  exit 1
fi

if [ ! -d "$ZEPHYR_SDK_INSTALL_DIR" ]; then
  echo "Zephyr SDK not found at: $ZEPHYR_SDK_INSTALL_DIR" >&2
  echo "Install Zephyr SDK 0.16.x and set ZEPHYR_SDK_INSTALL_DIR." >&2
  exit 1
fi

if [ ! -x ".venv/bin/west" ]; then
  python3 -m venv .venv
  .venv/bin/pip install --upgrade pip
  .venv/bin/pip install west pyelftools
fi

if [ ! -d ".west" ]; then
  .venv/bin/west init -l config
fi

if [ ! -d "zmk" ] || [ ! -d "zephyr" ] || [ ! -d "modules" ]; then
  .venv/bin/west update
fi

.venv/bin/west zephyr-export

ZMK_CONFIG="$ROOT/config"
ZMK_EXTRA_MODULES="$ROOT/config"

rm -rf "$ROOT/build/left" "$ROOT/build/right"

.venv/bin/west build -s zmk/app -b xiao_ble -d build/left -- \
  -DSHIELD=corne_xiao_left \
  -DZMK_CONFIG="$ZMK_CONFIG" \
  -DZMK_EXTRA_MODULES="$ZMK_EXTRA_MODULES"

.venv/bin/west build -s zmk/app -b xiao_ble -d build/right -- \
  -DSHIELD=corne_xiao_right \
  -DZMK_CONFIG="$ZMK_CONFIG" \
  -DZMK_EXTRA_MODULES="$ZMK_EXTRA_MODULES"

LEFT_UF2="$ROOT/build/left/zephyr/zmk.uf2"
RIGHT_UF2="$ROOT/build/right/zephyr/zmk.uf2"

OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/output}"
mkdir -p "$OUTPUT_DIR"

cp -f "$LEFT_UF2" "$OUTPUT_DIR/corne_xiao_left.uf2"
cp -f "$RIGHT_UF2" "$OUTPUT_DIR/corne_xiao_right.uf2"

echo
echo "UF2 outputs:"
echo "  Left : $LEFT_UF2"
echo "  Right: $RIGHT_UF2"
echo
echo "Copied to:"
echo "  $OUTPUT_DIR/corne_xiao_left.uf2"
echo "  $OUTPUT_DIR/corne_xiao_right.uf2"

