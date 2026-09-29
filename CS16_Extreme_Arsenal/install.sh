#!/usr/bin/env bash
set -euo pipefail
SERVER_ROOT="${1:-}"
if [[ -z "$SERVER_ROOT" || ! -d "$SERVER_ROOT" ]]; then
  echo "Usage: $0 /path/to/cstrike" >&2
  exit 1
fi
cp -r models sound sprites "$SERVER_ROOT/"
mkdir -p "$SERVER_ROOT/addons/amxmodx/scripting/include" "$SERVER_ROOT/addons/amxmodx/configs"
cp addons/amxmodx/scripting/felix_zombie_expansion.sma "$SERVER_ROOT/addons/amxmodx/scripting/"
cp addons/amxmodx/scripting/include/*.inc "$SERVER_ROOT/addons/amxmodx/scripting/include/"
cp addons/amxmodx/configs/felix_zombie_expansion.cfg "$SERVER_ROOT/addons/amxmodx/configs/"
echo "Assets and source installed. Compile felix_zombie_expansion.sma with AMX Mod X amxxpc, then add the .amxx to plugins-zplague.ini."
