#!/usr/bin/env bash

# 1. Переменные
IP_ADDRESS="149.154.167.220"
DOMAIN="my.telegram.org"
HOSTS_FILE="/etc/hosts"
ENTRY="${IP_ADDRESS} ${DOMAIN}"

# 2. Проверка прав суперпользователя (root) — выводится только при ошибке
if [ "$EUID" -ne 0 ]; then
  echo "❌ Ошибка: Запустите скрипт через sudo."
  echo "Пример: sudo bash $0"
  exit 1
fi

# 3. Удаление старых записей (вывод ошибок и логов подавлен)
if grep -q "$DOMAIN" "$HOSTS_FILE" 2>/dev/null; then
  sed -i.bak "/$DOMAIN/d" "$HOSTS_FILE" 2>/dev/null || sed -i "" "/$DOMAIN/d" "$HOSTS_FILE" 2>/dev/null
fi

# 4. Добавление новой записи (вывод подавлен)
echo "$ENTRY" >> "$HOSTS_FILE" 2>/dev/null

# 5. Очистка кэша DNS (вывод всех команд перенаправлен в /dev/null)
if [[ "$OSTYPE" == "darwin"* ]]; then
  sudo killall -HUP mDNSResponder >/dev/null 2>&1
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    sudo resolvectl flush-caches >/dev/null 2>&1
  fi
fi
echo "Done!"
