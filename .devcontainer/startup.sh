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

# Wait for server to be ready (check /health endpoint)
echo "⏳ Waiting for server to start..."
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo "✅ Server is ready and responding!"
        echo "📝 Logs: /tmp/server.log"
        echo "🔗 Port: 3000"
        echo "🌐 Health check: http://localhost:3000/health"
        exit 0
    fi

    ATTEMPT=$((ATTEMPT + 1))
    echo "   Attempt $ATTEMPT/$MAX_ATTEMPTS..."
    sleep 1
done

echo "❌ Server failed to start after 30 seconds"
echo "📝 Check logs: tail -f /tmp/server.log"
ps -p $SERVER_PID > /dev/null && echo "⚠️  Process is running but not responding on port 3000"
exit 1
