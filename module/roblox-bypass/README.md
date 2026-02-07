# Roblox Bypass (KernelSU/Magisk)

Минимальный модуль, который делает две вещи **только для Roblox**:
- Редирект DNS на локальный DoH‑прокси (например, `cloudflared`).
- Опционально блокирует UDP/443 (QUIC), чтобы приложение ушло на TCP.

## Установка
1. Заархивируйте папку `module/roblox-bypass` в zip.
2. Установите zip через KernelSU/Magisk.
3. Перезагрузите телефон.

## Настройка
Файл конфигурации: `/data/adb/roblox-bypass/config.conf`

Параметры:
```
ENABLE_DNS_REDIRECT=1
DNS_PORT=5053
START_CLOUDFLARED=0
CLOUDFLARED_BIN=/data/adb/roblox-bypass/cloudflared

BLOCK_UDP_443=0

# Пакеты Roblox (через пробел)
PACKAGE_NAMES="com.roblox.client"

# Можно указать UID вручную (если знаешь)
# ROBLOX_UIDS="10123 10124"
```

## cloudflared (DoH без VPN)
1. Положите бинарник `cloudflared` в `/data/adb/roblox-bypass/cloudflared`
2. `chmod +x /data/adb/roblox-bypass/cloudflared`
3. Поставьте `START_CLOUDFLARED=1`

## Логи
`/data/adb/roblox-bypass/log.txt`
