#!/bin/bash

# Config
MYSQL_USER="root"
MYSQL_PASS="password"
MYSQL_DB="testdb"
MYSQL_TABLE="sensor_data"
LOG_FILE="latency_log.txt"
TRACK_FILE="produced_events.txt"

echo "[INFO] Starting latency measurement..."
> "$LOG_FILE"

max_attempts=30
attempt=0

get_current_millis() {
  python3 -c "import time; print(int(time.time() * 1000))"
}

while [[ $attempt -lt $max_attempts ]]; do
    while IFS=, read -r id send_time; do
        # Skip if already logged
        if grep -q "^$id," "$LOG_FILE"; then
            continue
        fi

        # Query MySQL for this ID
        found=$(docker exec -i c1072f1dc81106e6de30d774ba4319240c27e9583946dd2c69053a936e52d080 mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -D"$MYSQL_DB" -sN -e \
        "SELECT COUNT(*) FROM $MYSQL_TABLE WHERE id=$id;")

        if [[ "$found" -gt 0 ]]; then
            now_ms=$(get_current_millis)

            # Debug prints for troubleshooting
            echo "[DEBUG] id=$id, send_time=$send_time, now_ms=$now_ms"

            latency=$((now_ms - send_time))
            echo "[INFO] ID=$id latency=${latency}ms"
            echo "$id,$latency" >> "$LOG_FILE"
        fi
    done < "$TRACK_FILE"

    sleep 1
    ((attempt++))
done

echo "[INFO] Latency measurement complete. See $LOG_FILE"
