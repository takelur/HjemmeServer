@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Sti til skriptet
SET "SCRIPT_DIR=%~dp0"

:: Sti til loggfil
SET "LOG_FILE=%SCRIPT_DIR%wakeonlan.log"

SET "TARGET_IP=xxx.xxx.xxx.xxx"
SET "TARGET_MAC=xx:xx:xx:xx:xx:xx"

:: Discord Webhook URL
SET "DISCORD_WEBHOOK_URL=hemmelig.no"

:: Sjekker om maskin kjører
ping -n 1 %TARGET_IP% >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    CALL :LOG_WITH_TIMESTAMP "Maskinen kjører ikke, sender Wake-on-LAN signal..."
    :: Husk at du trenger en WoL utility på Windows, bare å endre til rett path/utility kommando i framtiden
    "C:\path\to\WakeMeOnLan.exe" /wakeup %TARGET_MAC%
    CALL :SEND_DISCORD_NOTIFICATION "Wake-on-LAN signal ble sent til Vær-PC"
) ELSE (
    CALL :LOG_WITH_TIMESTAMP "Maskinen kjører allerede, utfører ingen handling."
)
GOTO :EOF

:: Simpel logg
:LOG_WITH_TIMESTAMP
SET "log_message=%1"
echo [%DATE% %TIME%]: %log_message% >> %LOG_FILE%
GOTO :EOF

:: Sender varsel
:SEND_DISCORD_NOTIFICATION
SET "message=%~1"
curl -H "Content-Type: application/json" -d "{\"content\": \"%message%\"}" %DISCORD_WEBHOOK_URL%
GOTO :EOF
