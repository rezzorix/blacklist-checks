#!/bin/bash

# Define your AbuseIPDB API key and Discord webhook URL
API_KEY="YOUR-API-KEY"
DISCORD_WEBHOOK_URL="YOUR DISCORD-WEBHOOK-URL"

# Function to check IP and send Discord notification if blacklisted
check_ip() {
  local ip=$1
  response=$(curl -s -G https://api.abuseipdb.com/api/v2/check \
    --data-urlencode "ipAddress=$ip" \
    -d maxAgeInDays=90 \
    -d verbose \
    -H "Key: $API_KEY" \
    -H "Accept: application/json")

  abuse_confidence_score=$(echo $response | jq '.data.abuseConfidenceScore')

  if [ "$abuse_confidence_score" -gt 0 ]; then
    send_discord_notification "$ip"
    echo "$ip: blacklisted"
  else
    echo "$ip: clean"
  fi
}

# Function to send Discord notification
send_discord_notification() {
  local ip=$1
  curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Warning: IP $ip blacklisted in AbuseIPDB\"}" $DISCORD_WEBHOOK_URL
}

# Get the external IP address
external_ip=$(curl -s http://whatismyip.akamai.com/)

# Array of IPs to check
ips=(
  "IP1"
  "IP2"
  "IP3"
  "$external_ip" # if run e.g. on homeserver checks public ip of server this script is running on
)

# Loop through the array and check each IP
for ip in "${ips[@]}"; do
  check_ip $ip
done

