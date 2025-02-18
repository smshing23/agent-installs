#!/bin/bash 
# 
# CloudRadial Mac Agent Installer 
# Optimized for compatibility across Intel and Apple Silicon Macs 
# Intended for use with ConnectWise Asio 
# 
# Variables (pre-filled with your service and partner URLs) 
SERVICE_ENDPOINT="https://veit.services-us6.cloudradial.com" 
PARTNER_URL="https://veit.us.cloudradial.com" 
COMPANY_ID="$1" 
# Company ID from CloudRadial portal 
SECURITY_KEY="" 
# Optional security key 
LOG_FILE="/Library/Logs/cloudradial.mac.agent_install.log" 
# Log file for script output 
# Strong check to ensure the script only runs on macOS 
if [[ "$(uname)" != "Darwin" ]]; then echo "This script is intended to run on macOS only. Skipping." | tee -a "$LOG_FILE" exit 0 
# Exit with success to avoid partial failure reporting in Asio 
fi 
# Ensure required fields are filled 
if [ -z "$SERVICE_ENDPOINT" ]; then echo "Error: Please enter a valid service endpoint URL." | tee -a "$LOG_FILE" exit 1 fi 
if [ -z "$PARTNER_URL" ]; then echo "Error: Please enter a valid partner URL." | tee -a "$LOG_FILE" exit 1 fi 
if [ -z "$COMPANY_ID" ]; then echo "Error: Please enter a valid company ID." | tee -a "$LOG_FILE" exit 1 fi 
echo "CloudRadial Mac Agent Installer" | tee -a "$LOG_FILE" echo "Service Endpoint: $SERVICE_ENDPOINT" | tee -a "$LOG_FILE" echo "Partner URL: $PARTNER_URL" | tee -a "$LOG_FILE" echo "Company ID: $COMPANY_ID" | tee -a "$LOG_FILE" echo "Security Key: $SECURITY_KEY" | tee -a "$LOG_FILE" echo "" | tee -a "$LOG_FILE" 
# Check if the agent is already installed 
if [ -f "/Library/LaunchDaemons/com.cloudradial.mac.agent.plist" ]; then echo "CloudRadial Mac agent already installed. Exiting." | tee -a "$LOG_FILE" exit 0 fi 
# Stop daemon if already running 
if launchctl list | grep -q "cloudradial.mac.agent"; then echo "Stopping existing CloudRadial Mac agent." | tee -a "$LOG_FILE" 
sudo launchctl unload /Library/LaunchDaemons/com.cloudradial.mac.agent.plist 2>>"$LOG_FILE" fi 
# Remove 'KeepAlive' setting if present 
sudo plutil -remove KeepAlive /Library/LaunchDaemons/com.cloudradial.mac.agent.plist 2>/dev/null 
# Detect architecture and download the appropriate package 
ARCH=$(uname -p) PKG_URL="" 
if [[ "$ARCH" == 'arm' ]]; then echo "Installing for Apple Silicon (M1, M2)" | tee -a "$LOG_FILE" 
PKG_URL="https://cloudradialagent.blob.core.windows.net/macagent/cloudradial.mac.agent-arm64.pkg" 
elif [[ "$ARCH" == 'i386' ]]; then echo "Installing for Intel" | tee -a "$LOG_FILE" 
PKG_URL="https://cloudradialagent.blob.core.windows.net/macagent/cloudradial.mac.agent-x64.pkg" 
else echo "Error: Unsupported architecture." | tee -a "$LOG_FILE" exit 1 fi 
# Retry logic for downloading the package 
attempts=0 max_attempts=3 while [ $attempts -lt $max_attempts ]; do curl -s "$PKG_URL" --output /tmp/cloudradial.mac.agent.pkg 
if [ $? -eq 0 ]; then echo "Download successful." | tee -a "$LOG_FILE" break fi 
attempts=$((attempts+1)) echo "Download attempt $attempts failed. Retrying in 10 seconds..." | tee -a "$LOG_FILE" sleep 10 done 
if [ $attempts -eq $max_attempts ]; then echo "Error: Failed to download package after $max_attempts attempts." | tee -a "$LOG_FILE" exit 1 fi 
# Install the package 
sudo installer -pkg /tmp/cloudradial.mac.agent.pkg -target / 2>>"$LOG_FILE" 
if [ $? -ne 0 ]; then echo "Error: Installation failed." | tee -a "$LOG_FILE" exit 1 fi 
# Clean up downloaded package 
rm -f /tmp/cloudradial.mac.agent.pkg 
# Update plist with correct settings for partner and company 
sudo plutil -remove ProgramArguments /Library/LaunchDaemons/com.cloudradial.mac.agent.plist 2>/dev/null 
sudo plutil -insert ProgramArguments -xml "<array><string>/Library/LaunchDaemons/CloudRadial.Mac.Agent/CloudRadial.Mac.Agent</string><string>$SERVICE_ENDPOINT</string><string>$PARTNER_URL</string><string>$COMPANY_ID</string><string>$SECURITY_KEY</string></array>" /Library/LaunchDaemons/com.cloudradial.mac.agent.plist 
# Ensure KeepAlive is set to true 
sudo plutil -remove KeepAlive /Library/LaunchDaemons/com.cloudradial.mac.agent.plist 2>/dev/null sudo plutil -insert KeepAlive -bool true /Library/LaunchDaemons/com.cloudradial.mac.agent.plist 
# Load the daemon 
sudo launchctl load /Library/LaunchDaemons/com.cloudradial.mac.agent.plist # Display daemon status 
sudo launchctl list | grep "cloudradial.mac.agent" | tee -a "$LOG_FILE" 
# Ensure the script exits with a success code 
echo "Script execution completed." | tee -a "$LOG_FILE" exit 0
