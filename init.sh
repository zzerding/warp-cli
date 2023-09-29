#!/bin/bash

set -e  # Set error exit

# Run the "exit" command when receiving SIGNAL
cleanup(){
    echo "Received stop signal. Stopping services..."
    warp-cli disconnect
    pkill -9 warp-svc
    pkill -9 tail
    echo "Services stopped. Exiting..."
    exit 0
}

trap 'cleanup' SIGINT SIGTERM

# Define the log file path
mkdir -p /var/log/warp
LOG_FILE=/var/log/warp/warp-svc.log

# Start the "warp-svc" service and redirect its output to the log file
if [ -n "$DEBUG_WARP" ]; then
  echo "start DEBUG warp"
  warp-svc >> "$LOG_FILE" 2>&1 &
fi
if [ -z "$DEBUG_WARP"  ]; then
  #delete warp debug log
  mkdir -p /var/lib/cloudflare-warp
  rm -rf /var/lib/cloudflare-warp/*
  base_path=/var/lib/cloudflare-warp	
  ln -s /dev/null $base_path/cfwarp_daemon_dns.txt
  ln -s /dev/null $base_path/cfwarp_service_boring.txt
  ln -s /dev/null $base_path/cfwarp_service_dns_stats.txt
  ln -s /dev/null $base_path/cfwarp_service_log.txt
  ln -s /dev/null $base_path/cfwarp_service_stats.txt
  echo "start warp-svc"
  warp-svc | grep -v DEBUG  "$LOG_FILE" 2>&1 &
fi

# Wait for 2 seconds to allow the service to start
sleep 2

# Automatically register
warp-cli --accept-tos register

# If the environment variable WARP_KEY exists, set the license
if [ -n "$WARP_KEY" ]; then
  echo "Setting Warp license..."
  env >> "$LOG_FILE"  # Append the output of the env command to the log file
  warp-cli --accept-tos set-license "$WARP_KEY"
fi

# If the environment variable WARP_PORT exists, set the proxy port
if [ -n "$WARP_PORT" ]; then
  echo "Setting Warp proxy port to $WARP_PORT..."
  warp-cli --accept-tos set-proxy-port "$WARP_PORT"
fi

# Set the proxy mode
echo "Setting Warp mode to proxy..."
warp-cli --accept-tos set-mode proxy

# disaple dns log
echo "disable dns log"
warp-cli --accept-tos disable-dns-log

# Connect to the Warp service
echo "Connecting to Warp service..."
warp-cli --accept-tos connect

# Output logs for monitoring script execution
echo "Warp configuration completed. Monitoring logs..."
tail -f  "$LOG_FILE" & wait
