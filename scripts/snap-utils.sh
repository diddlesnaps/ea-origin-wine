#!/bin/bash

if [ "$WINE_ARCH" = "amd64" ]; then
    GAMES_LIBRARY="$WINEPREFIX/Program Files (x86)/Origin Games"
else
    GAMES_LIBRARY="$WINEPREFIX/Program Files/Origin Games"
fi

if [ ! -d "$GAMES_LIBRARY" ]; then
    mkdir -p "$GAMES_LIBRARY"
fi

MONITORED_DIR="$(dirname "$2")"

if [ "$SNAP_ARCH" = "amd64" ]; then
    MONITORED_DIR="${MONITORED_DIR/"Program Files"/"Program Files (x86)"}"
fi

PIDFILE="$SNAP_USER_COMMON/.inotify-pid"
KILLFILE="$SNAP_USER_COMMON/.kill-monitor"

if [ -f "$PIDFILE" ]; then
    touch "$KILLFILE"
    kill "$(cat "$PIDFILE")"
    sleep 2
    rm -f "$KILLFILE" "$PIDFILE"
fi

function start_monitor() {
    INOTIFY_PID=
    start_timer &
    while [ ! -f "$KILLFILE" ]; do
        [ ! -d "$MONITORED_DIR" ] && continue
        chmod 755 "$MONITORED_DIR"
        inotifywait -e create,attrib "$MONITORED_DIR" &
        INOTIFY_PID=$!
        echo $INOTIFY_PID > "$PIDFILE"
        wait $INOTIFY_PID
    done &
}

function start_timer() {
    sleep 600
    [ ! -f "$PIDFILE" ] || [ -z "$(cat "$PIDFILE")" ] && touch "$KILLFILE"
}
