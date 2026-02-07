#!/system/bin/sh
CONF="/data/adb/roblox-bypass/config.conf"

load_conf() {
  if [ -f "$CONF" ]; then
    # shellcheck disable=SC1090
    . "$CONF"
  fi
}

get_uids() {
  if [ -n "${ROBLOX_UIDS:-}" ]; then
    echo "$ROBLOX_UIDS"
    return
  fi
  if command -v cmd >/dev/null 2>&1; then
    for pkg in ${PACKAGE_NAMES:-}; do
      local line
      line="$(cmd package list packages -U "$pkg" 2>/dev/null | head -n 1)"
      if [ -n "$line" ]; then
        echo "$line" | awk -F'uid:' '{print $2}' | tr -d ' '
      fi
    done
  fi
}

iptables_cmd() {
  if command -v iptables >/dev/null 2>&1; then
    iptables "$@"
  fi
}

remove_rules() {
  local port="${DNS_PORT:-5053}"
  local uids
  uids="$(get_uids)"
  for uid in $uids; do
    iptables_cmd -t nat -D OUTPUT -p udp --dport 53 -m owner --uid-owner "$uid" -j REDIRECT --to-ports "$port" 2>/dev/null
    iptables_cmd -t nat -D OUTPUT -p tcp --dport 53 -m owner --uid-owner "$uid" -j REDIRECT --to-ports "$port" 2>/dev/null
    iptables_cmd -D OUTPUT -p udp --dport 443 -m owner --uid-owner "$uid" -j REJECT 2>/dev/null
  done
}

load_conf
remove_rules
rm -f /data/adb/roblox-bypass/log.txt
