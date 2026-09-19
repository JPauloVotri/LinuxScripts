#!/usr/bin/env bash

STEP=5
MAX_VOLUME=100
MSG_ID="991049"

get_volume_info() {
    local SINK_INFO=$(pactl get-sink-volume @DEFAULT_SINK@)
    local MUTE_STATUS=$(pactl get-sink-mute @DEFAULT_SINK@)

    VOLUME=$(echo "$SINK_INFO" | grep -oP '\d+(?=%)' | head -1)

    if echo "$MUTE_STATUS" | grep -q "yes"; then
        MUTED=true
    else
        MUTED=false
    fi
}

show_volume_notification() {
    local ICON=""
    local TEXT=""

    if [ "$MUTED" = true ]; then
        ICON="audio-volume-muted-symbolic"
        TEXT="Mudo"
    else
        if [ "$VOLUME" -lt 33 ]; then
            ICON="audio-volume-low-symbolic"
        elif [ "$VOLUME" -lt 66 ]; then
            ICON="audio-volume-medium-symbolic"
        else
            ICON="audio-volume-high-symbolic"
        fi
        TEXT="Volume: ${VOLUME}%"
    fi

    notify-send -a "Volume" -u low -i "$ICON" -h int:value:"$VOLUME" \
        -r "$MSG_ID" -t 1000 "$TEXT"
}

if [ "$2" = "high" ]; then
    INCREMENT=$((STEP * 2))
else
    INCREMENT=$STEP
fi

case "$1" in
    up)
        get_volume_info
        if [ "$MUTED" = true ]; then
            pactl set-sink-mute @DEFAULT_SINK@ 0
            get_volume_info
        fi

        NEW_VOLUME=$((VOLUME + INCREMENT))
        if [ "$NEW_VOLUME" -gt "$MAX_VOLUME" ]; then
            NEW_VOLUME="$MAX_VOLUME"
        fi

        pactl set-sink-volume @DEFAULT_SINK@ "${NEW_VOLUME}%"
        get_volume_info
        show_volume_notification
        ;;

    down)
        get_volume_info
        NEW_VOLUME=$((VOLUME - INCREMENT))
        if [ "$NEW_VOLUME" -lt 0 ]; then
            NEW_VOLUME=0
        fi

        pactl set-sink-volume @DEFAULT_SINK@ "${NEW_VOLUME}%"
        get_volume_info
        show_volume_notification
        ;;

    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        get_volume_info
        show_volume_notification
        ;;

    *)
        echo "Uso: $0 {up|down|mute} [high]"
        echo "  up/down      - Ajusta volume em $STEP%"
        echo "  high         - Ajusta volume em $(($STEP * 2))%"
        echo "  mute         - Alterna mudo"
        exit 1
        ;;
esac