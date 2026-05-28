#!/usr/bin/env bash

LOW_BATTERY=${BATTERY_LOW:-20}
CRITICAL_BATTERY=${BATTERY_CRITICAL:-5}

BAT_PATH=$(upower -e | grep -i 'bat' | head -n1)

if [ -z "$BAT_PATH" ]; then
    echo "Nenhuma bateria encontrada pelo upower."
    exit 1
fi

BATTERY_PERCENT=$(upower -i "$BAT_PATH" | grep percentage | awk '{print $2}' | sed 's/%//')
BATTERY_STATUS=$(upower -i "$BAT_PATH" | grep state | awk '{print $2}')

if [[ "$BATTERY_STATUS" != "charging" ]] && [[ "$BATTERY_STATUS" != "fully-charged" ]]; then
    if [ "$BATTERY_PERCENT" -le "$CRITICAL_BATTERY" ]; then
        notify-send -u critical -a "battery" -i battery-empty-symbolic \
        "Nível Crítico de Bateria!" \
        "Nível em ${BATTERY_PERCENT}%. Conecte o carregador imediatamente."
    elif [ "$BATTERY_PERCENT" -le "$LOW_BATTERY" ]; then
        notify-send -u normal -a "battery" -i battery-low-symbolic \
        "Bateria Fraca" \
        "Nível em ${BATTERY_PERCENT}%. Procure um carregador em breve."
    fi
fi