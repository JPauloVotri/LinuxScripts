#!/usr/bin/env bash

BASE_STEP=10

case $2 in
    low)
        STEP=$((BASE_STEP / 2))
        ;;
    *)
        STEP=$BASE_STEP
esac

case $1 in
    up)
        brightnessctl set ${STEP}%+
        ;;
    down)
        brightnessctl set ${STEP}%-
        ;;
    *)
        echo "Uso: $(basename $0) {up|down} [low]"
        exit 1
esac

CURRENT=$(brightnessctl -m | grep -oE '[0-9]+%' | head -1 | tr -d '%')

ICON="brightness"

dunstify -a "brightness_progress" -u low -i "$ICON" \
    -h string:x-dunst-stack-tag:brightness \
    -h int:value:"$CURRENT" \
    -t 2000 \
    "Brilho: ${CURRENT}%"
