#!/bin/bash

# ¨Gjeldende filsti
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Sti til loggfil
LOG_FILE="$SCRIPT_DIR/wakeonlan.log"

TARGET_IP="xxx.xxx.xxx.xxx"
TARGET_MAC="xx:xx:xx:xx:xx:xx"

# Discord Webhook URL
DISCORD_WEBHOOK_URL="hemmelig.no"

# Sender webhook notis
send_discord_notification() {
    local message=$1
    curl -H "Content-Type: application/json" -d "{\"content\": \"$message\"}" $DISCORD_WEBHOOK_URL
}

# Sjekker om maskin er oppe og kjører
is_target_up() {
    ping -c 1 $TARGET_IP &> /dev/null
    return $?
}

# Enkel logg med timestamp
log_with_timestamp() {
    echo "$(date): $1" >> $LOG_FILE
}

# MAIN logikk
if ! is_target_up; then
    log_with_timestamp "Maskinen kjører ikke, sender Wake-on-LAN signal..."
    etherwake -b -i ens18 $TARGET_MAC
    send_discord_notification "Wake-on-LAN signal ble sent til Vær-PC"
else
    log_with_timestamp "Maskinen kjører allerede, utfører ingen handling."
fi
