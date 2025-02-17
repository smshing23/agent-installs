#!/bin/bash 
SERVICE_ENDPOINT="https://veit.services-us6.cloudradial.com" 
PARTNER_URL="https://veit.us.cloudradial.com" 
COMPANY_ID="$1"
# Stop daemon if already running
#if [[ $(launchctl list | grep com.cloudradial.mac.agent) ]]; then
#    launchctl unload /Library/LaunchDaemons/com.cloudradial.mac.agent.plist
#    plutil -remove KeepAlive /Library/LaunchDaemons/com.cloudradial.mac.agent.plist
#fi
# Download current package
if [[ $(uname -p) == 'arm' ]]; then
    echo "Installing for Apple M1"
    sudo curl https://cloudradialagent.blob.core.windows.net/macagent/cloudradial.mac.agent-arm64.pkg --output /tmp/cloudradial.mac.agent-arm64.pkg
    sudo installer -pkg /tmp/cloudradial.mac.agent-arm64.pkg -target /
elif
    echo "Installing for Intel"
    curl https://cloudradialagent.blob.core.windows.net/macagent/cloudradial.mac.agent-x64.pkg --output /tmp/cloudradial.mac.agent-x64.pkg
    sudo installer -pkg /tmp/cloudradial.mac.agent-x64.pkg -target /
fi
# Update plist with correct settings for partner and company
plutil -remove ProgramArguments /Library/LaunchDaemons/com.cloudradial.mac.agent.plist > /dev/null
plutil -insert ProgramArguments -xml "<array><string>/Library/LaunchDaemons/CloudRadial.Mac.Agent/CloudRadial.Mac.Agent</string><string>$SERVICE_ENDPOINT</string><string>$PARTNER_URL</string><string>$COMPANY_ID</string><string></string></array>" /Library/LaunchDaemons/com.cloudradial.mac.agent.plist
# Set to always run
plutil -remove KeepAlive /Library/LaunchDaemons/com.cloudradial.mac.agent.plist
plutil -insert KeepAlive -bool true /Library/LaunchDaemons/com.cloudradial.mac.agent.plist
# Load the daemon
launchctl load /Library/LaunchDaemons/com.cloudradial.mac.agent.plist
# Display daemon status
launchctl list cloudradial.mac.agent
