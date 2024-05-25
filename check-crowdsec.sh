#!/bin/bash

# Define your CrowdSec API key and Discord webhook URL
CROWDSEC_API_KEY="YOUR-APIP-KEY" # Replace with your actual CrowdSec API key
DISCORD_WEBHOOK_URL="YOUR-DISCORD-WEBHOOK-URL"

# Function to check IP and send Discord notification if blacklisted
check_ip() {
  local ip=$1
  response=$(curl -s -X GET "https://cti.api.crowdsec.net/v2/smoke/$ip" \
    -H "x-api-key: $CROWDSEC_API_KEY" \
    -H "Accept: application/json")

  echo "Response for IP $ip: $response"  # Debugging statement

  message=$(echo $response | jq -r '.message')
  reputation=$(echo $response | jq -r '.reputation')

  if [ "$message" == "Too Many Requests" ]; then
    echo "$ip: rate limited, retrying after delay"
    sleep 10  # Sleep for 10 seconds before retrying
    check_ip $ip  # Retry the same IP
  elif [ "$message" == "IP address information not found" ]; then
    echo "$ip: information not found"
  elif [ "$reputation" == "malicious" ] || [ "$reputation" == "suspicious" ]; then
    send_discord_notification "$ip"
    echo "$ip: blacklisted"
  else
    echo "$ip: clean"
  fi
}

# Function to send Discord notification
send_discord_notification() {
  local ip=$1
  curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Warning: IP $ip blacklisted in Crowdsec\"}" $DISCORD_WEBHOOK_URL
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
