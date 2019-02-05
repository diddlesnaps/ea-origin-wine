#!/bin/bash

if [ "$WINE_ARCH" = "amd64" ]; then
    GAMES_LIBRARY="$WINEPREFIX/Program Files (x86)/Origin Games"
else
    GAMES_LIBRARY="$WINEPREFIX/Program Files/Origin Games"
fi

if [ ! -d "$GAMES_LIBRARY" ]; then
    mkdir -p "$GAMES_LIBRARY"
fi

MONITORED_DIR="$WINE_DIR"

if [ ! -d "$MONITORED_DIR" ]; then
    mkdir -p "$MONITORED_DIR"
fi

function kill_monitor() {
    pkill --parent "$(cat "$PIDFILE")" inotifywait
}

function start_monitor() {
    kill_monitor
    sleep 1

    INOTIFY_PID=
    start_timer &

    inotifywait -e attrib "$MONITORED_DIR" | while read path action file; do
        [ ! -w "$MONITORED_DIR" ] && chmod 755 "$MONITORED_DIR"
    done &
    INOTIFY_PID=$!
    echo $INOTIFY_PID > "$PIDFILE"
}

function start_timer() {
    sleep 600
    if [ ! -f "$PIDFILE" ] || [ -z "$(cat "$PIDFILE")" ]; then
        kill_monitor
    fi
}
