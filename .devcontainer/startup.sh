#!/bin/bash

# Startup script for Codespace
echo "🚀 Starting Twilio Voice AI Workshop server..."

# Make port 3000 public
bash .devcontainer/setup.sh

# Find the workspace directory
WORKSPACE_DIR=$(find /workspaces -maxdepth 1 -type d -not -name workspaces | head -1)
cd "$WORKSPACE_DIR"

# Kill any existing node processes
pkill -f "node.*server.js" || true

# Start the server with nohup and disown to survive command exit
nohup npm start > /tmp/server.log 2>&1 &
SERVER_PID=$!
disown $SERVER_PID

# Wait a moment for server to start
sleep 3

# Verify server is running
if ps -p $SERVER_PID > /dev/null; then
    echo "✅ Server started successfully (PID: $SERVER_PID)"
    echo "📝 Logs: /tmp/server.log"
    echo "🔗 Port: 3000"
else
    echo "❌ Server failed to start. Check /tmp/server.log"
    exit 1
fi
