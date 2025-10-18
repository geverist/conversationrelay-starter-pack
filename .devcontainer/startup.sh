#!/bin/bash

# Startup script for Codespace
echo "🚀 Starting Twilio Voice AI Workshop server..."

# Make port 3000 public
bash .devcontainer/setup.sh

# Start the server in the background
cd /workspaces/*/
nohup npm start > /tmp/server.log 2>&1 &

echo "✅ Server started! Check logs at /tmp/server.log"
echo "🔗 Server will be available at port 3000"
