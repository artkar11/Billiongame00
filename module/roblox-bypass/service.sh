#!/system/bin/sh
MODDIR="${0%/*}"
CONF="/data/adb/roblox-bypass/config.conf"
LOG="/data/adb/roblox-bypass/log.txt"

log() {
  echo "$(date '+%F %T') $*" >> "$LOG"
}

get_uids() {
  local uids=""
  if [ -n "${ROBLOX_UIDS:-}" ]; then
    echo "$ROBLOX_UIDS"
    return
  fi
  if command -v cmd >/dev/null 2>&1; then
    for pkg in ${PACKAGE_NAMES:-}; do
      local line
      line="$(cmd package list packages -U "$pkg" 2>/dev/null | head -n 1)"
      if [ -n "$line" ]; then
        uids="${uids} $(echo "$line" | awk -F'uid:' '{print $2}' | tr -d ' ')"
      else
        log "package not found: $pkg"
      fi
    done
  else
    log "cmd not found; cannot resolve package UIDs"
  fi
  echo "$uids"
}

load_conf() {
  if [ -f "$CONF" ]; then
    # shellcheck disable=SC1090
    . "$CONF"
  fi
}

ensure_dirs() {
  mkdir -p /data/adb/roblox-bypass
  touch "$LOG"
}

iptables_cmd() {
  if command -v iptables >/dev/null 2>&1; then
    iptables "$@"
  else
    log "iptables not found"
  fi
}

setup_dns_redirect() {
  if [ "${ENABLE_DNS_REDIRECT:-0}" = "1" ]; then
    local port="${DNS_PORT:-5053}"
    local uids
    uids="$(get_uids)"
    if [ -z "$uids" ]; then
      log "no UIDs found; DNS redirect skipped"
      return
    fi
    for uid in $uids; do
      iptables_cmd -t nat -C OUTPUT -p udp --dport 53 -m owner --uid-owner "$uid" -j REDIRECT --to-ports "$port" 2>/dev/null || \
        iptables_cmd -t nat -A OUTPUT -p udp --dport 53 -m owner --uid-owner "$uid" -j REDIRECT --to-ports "$port"
      iptables_cmd -t nat -C OUTPUT -p tcp --dport 53 -m owner --uid-owner "$uid" -j REDIRECT --to-ports "$port" 2>/dev/null || \
        iptables_cmd -t nat -A OUTPUT -p tcp --dport 53 -m owner --uid-owner "$uid" -j REDIRECT --to-ports "$port"
    done
    log "DNS redirect enabled to 127.0.0.1:${port} for UIDs:${uids}"
  fi
}

setup_quic_block() {
  if [ "${BLOCK_UDP_443:-0}" = "1" ]; then
    local uids
    uids="$(get_uids)"
    if [ -z "$uids" ]; then
      log "no UIDs found; UDP/443 block skipped"
      return
    fi
    for uid in $uids; do
      iptables_cmd -C OUTPUT -p udp --dport 443 -m owner --uid-owner "$uid" -j REJECT 2>/dev/null || \
        iptables_cmd -A OUTPUT -p udp --dport 443 -m owner --uid-owner "$uid" -j REJECT
    done
    log "UDP/443 block enabled for UIDs:${uids}"
  fi
}

start_cloudflared_if_present() {
  if [ "${START_CLOUDFLARED:-0}" = "1" ]; then
    local bin="${CLOUDFLARED_BIN:-/data/adb/roblox-bypass/cloudflared}"
    local port="${DNS_PORT:-5053}"
    if [ -x "$bin" ]; then
      "$bin" proxy-dns --port "$port" --address 127.0.0.1 >/dev/null 2>&1 &
      log "cloudflared started on 127.0.0.1:${port}"
    else
      log "cloudflared not found or not executable at ${bin}"
    fi
  fi
}

ensure_dirs
load_conf
start_cloudflared_if_present
setup_dns_redirect
setup_quic_block
