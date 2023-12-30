#!/bin/bash

# Sti til skript
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Sti til loggfil
LOG_FILE="$SCRIPT_DIR/wakeonlan.log"

# Maks størrelse på loggfil i bytes (1 MB)
MAX_SIZE=$((1 * 1024 * 1024))

# Discord Webhook URL
DISCORD_WEBHOOK_URL=""

# Funksjon for å sende varsel
send_discord_notification() {
    local message=$1
    curl -H "Content-Type: application/json" -d "{\"content\": \"$message\"}" $DISCORD_WEBHOOK_URL
}

# MAIN logikk
if [[ -f "$LOG_FILE" ]]; then
    FILE_SIZE=$(stat -c%s "$LOG_FILE")

    if (( FILE_SIZE > MAX_SIZE )); then
        TEMP_FILE=$(mktemp)

        # Sletter de første 10000 linjene
        tail -n +10001 "$LOG_FILE" > "$TEMP_FILE"

        mv "$TEMP_FILE" "$LOG_FILE"

        # Sender varsel
        send_discord_notification "Reduserte loggfil, de første 10000 linjene er fjernet"
    fi
fi
