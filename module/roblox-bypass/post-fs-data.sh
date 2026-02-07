#!/system/bin/sh
mkdir -p /data/adb/roblox-bypass
if [ ! -f /data/adb/roblox-bypass/config.conf ]; then
  cat <<'EOF' > /data/adb/roblox-bypass/config.conf
# Roblox Bypass config
# 1 = enable, 0 = disable
ENABLE_DNS_REDIRECT=1
DNS_PORT=5053
START_CLOUDFLARED=0
CLOUDFLARED_BIN=/data/adb/roblox-bypass/cloudflared

BLOCK_UDP_443=0
# Packages to target (space-separated). Default Roblox app package:
PACKAGE_NAMES="com.roblox.client"
# Optional override if you already know UIDs (space-separated):
# ROBLOX_UIDS="10123 10124"
EOF
fi
