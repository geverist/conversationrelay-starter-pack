# 🎙️ ConversationRelay Starter Pack

Your AI-powered voice assistant built with [Twilio ConversationRelay](https://www.twilio.com/docs/voice/conversationrelay) and OpenAI Realtime API.

This starter pack provides a complete foundation for building sophisticated voice AI applications with real-time bidirectional streaming between callers and AI.

## 🚀 Quick Deploy

### Deploy to Railway
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/new)

### Deploy to Render
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

### Deploy to Heroku
[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## 📋 Prerequisites

- **Twilio Account** - [Sign up for free](https://www.twilio.com/try-twilio)
- **Twilio Phone Number** - With Voice capabilities
- **OpenAI API Key** - [Get your API key](https://platform.openai.com/api-keys)
- **Node.js 18+** - [Download Node.js](https://nodejs.org/)

## 🏗️ Architecture

```
┌─────────────┐         ┌─────────────────┐         ┌──────────────┐
│   Caller    │ ◄─────► │  Your Server    │ ◄─────► │   OpenAI     │
│   (Phone)   │  Voice  │  (This Project) │  API    │   Realtime   │
└─────────────┘         └─────────────────┘         └──────────────┘
                              │
                              │ TwiML
                              ▼
                        ┌─────────────┐
                        │   Twilio    │
                        │   Voice     │
                        └─────────────┘
```

### How It Works

1. **Incoming Call** → Twilio calls your `/voice-handler` endpoint
2. **TwiML Response** → Your server returns ConversationRelay TwiML
3. **WebSocket Connection** → Twilio connects to your WebSocket server
4. **Audio Streaming** → Real-time audio flows: Caller ↔ Your Server ↔ OpenAI
5. **AI Responses** → OpenAI generates responses, sent back to caller in real-time

## 🛠️ Local Setup

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/conversationrelay-starter-pack.git
cd conversationrelay-starter-pack
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

Create `.env` file:

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```bash
# Twilio Configuration
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890

# OpenAI Configuration
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Server Configuration
PORT=3000
```

### 4. Start Development Server

```bash
npm run dev
```

Server will start on `http://localhost:3000`

### 5. Expose Local Server with ngrok

Your server needs to be publicly accessible for Twilio webhooks.

```bash
# Install ngrok: https://ngrok.com/download
ngrok http 3000
```

Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`) and add to `.env`:

```bash
PUBLIC_URL=https://abc123.ngrok.io
```

Restart your server after adding `PUBLIC_URL`.

### 6. Configure Twilio Phone Number

1. Go to [Twilio Console → Phone Numbers](https://console.twilio.com/us1/develop/phone-numbers/manage/incoming)
2. Click on your phone number
3. Under **Voice & Fax**, set:
   - **A Call Comes In**: Webhook, `https://your-ngrok-url.ngrok.io/voice-handler`, HTTP POST
4. Click **Save**

### 7. Test Your Voice AI

Call your Twilio phone number and start talking to your AI!

## 📝 Development Workflow

### Project Structure

```
conversationrelay-starter-pack/
├── server.js                   # Express server + WebSocket setup
├── handlers/
│   ├── voice-handler.js        # TwiML generation (Step 4)
│   ├── websocket-handler.js    # ConversationRelay logic (Steps 5-6)
│   └── tools.js                # Function calling (Step 8)
├── config/
│   └── system-prompt.js        # AI personality (Step 7)
├── public/
│   └── index.html              # Status dashboard
├── .env                        # Environment variables (DO NOT COMMIT)
├── .env.example                # Example configuration
└── package.json                # Dependencies
```

### Step-by-Step Implementation

#### Step 4: Voice Handler (Basic Call Handling)

Edit `handlers/voice-handler.js`:

```javascript
function voiceHandler(callData, publicUrl) {
  const twiml = new VoiceResponse();
  twiml.say('Hello! Welcome to my voice AI.');
  return twiml;
}
```

#### Step 5-6: WebSocket Handler (ConversationRelay)

Edit `handlers/voice-handler.js` to use ConversationRelay:

```javascript
function voiceHandler(callData, publicUrl) {
  const twiml = new VoiceResponse();
  const connect = twiml.connect();
  connect.conversationRelay({
    url: `wss://${publicUrl.replace('https://', '').replace('http://', '')}`,
    voice: 'Polly.Joanna-Neural',
    dtmfDetection: true
  });
  return twiml;
}
```

Edit `handlers/websocket-handler.js` to add OpenAI integration:

```javascript
const openai = new OpenAI({ apiKey: openaiApiKey });
const openaiWs = openai.realtime.connect();

// Route messages between Twilio and OpenAI
ws.on('message', (message) => {
  const data = JSON.parse(message);
  if (data.event === 'media') {
    // Forward audio to OpenAI
    openaiWs.send(JSON.stringify({
      type: 'input_audio_buffer.append',
      audio: data.media.payload
    }));
  }
});

openaiWs.on('message', (message) => {
  const response = JSON.parse(message);
  if (response.type === 'response.audio.delta') {
    // Forward AI audio to Twilio
    ws.send(JSON.stringify({
      event: 'media',
      media: { payload: response.delta }
    }));
  }
});
```

#### Step 7: System Prompt

Edit `config/system-prompt.js`:

```javascript
const systemPrompt = `You are a helpful customer service representative.

Your role is to assist customers with their questions in a friendly, professional manner.

Keep responses concise (1-2 sentences) and always confirm understanding before proceeding.`;

module.exports = systemPrompt;
```

#### Step 8: Function Calling (Tools)

Edit `handlers/tools.js`:

```javascript
const tools = [
  {
    type: 'function',
    name: 'check_order_status',
    description: 'Check the status of a customer order',
    parameters: {
      type: 'object',
      properties: {
        orderId: {
          type: 'string',
          description: 'The order ID to look up'
        }
      },
      required: ['orderId']
    }
  }
];

async function executeToolCall(toolName, args) {
  switch (toolName) {
    case 'check_order_status':
      // Call your database/API
      return { status: 'shipped', trackingNumber: '1Z999AA1234567890' };
    default:
      return { error: 'Unknown tool' };
  }
}
```

## 🌐 Production Deployment

### Railway Deployment

1. Click "Deploy on Railway" button above
2. Add environment variables in Railway dashboard
3. Railway will provide a public URL automatically
4. Update Twilio phone number webhook to Railway URL

### Render Deployment

1. Click "Deploy to Render" button above
2. Add environment variables in Render dashboard
3. Render will provide a public URL automatically
4. Update Twilio phone number webhook to Render URL

### Heroku Deployment

1. Click "Deploy to Heroku" button above
2. Add environment variables (Config Vars) in Heroku dashboard
3. Heroku will provide a public URL automatically
4. Update Twilio phone number webhook to Heroku URL

### Custom Server Deployment

Deploy to any Node.js hosting platform:

```bash
# Build/prepare (if needed)
npm install --production

# Start production server
npm start
```

**Required Environment Variables:**
- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_PHONE_NUMBER`
- `OPENAI_API_KEY`
- `PUBLIC_URL` (your server's public URL)
- `PORT` (defaults to 3000)

## 🔒 Security Best Practices

1. **Never commit `.env`** - Already in `.gitignore`
2. **Use environment variables** - For all sensitive credentials
3. **Validate webhook signatures** - Add Twilio signature validation in production
4. **Rate limiting** - Implement rate limiting for public endpoints
5. **HTTPS only** - Always use HTTPS in production (HTTP not allowed for webhooks)
6. **Rotate credentials** - Regularly rotate API keys and auth tokens

## 🧪 Testing

### Test Server Status

```bash
curl http://localhost:3000/health
```

### Test Voice Handler

```bash
curl -X POST http://localhost:3000/voice-handler \
  -d "From=+15551234567" \
  -d "To=+15559876543"
```

### Test with Real Call

1. Call your Twilio phone number
2. Watch server logs: `npm run dev`
3. Check WebSocket connections in status dashboard: `http://localhost:3000`

## 📚 Resources

- [Twilio ConversationRelay Docs](https://www.twilio.com/docs/voice/conversationrelay)
- [OpenAI Realtime API Docs](https://platform.openai.com/docs/guides/realtime)
- [Twilio Voice Webhooks](https://www.twilio.com/docs/voice/twiml)
- [Node.js WebSocket (ws) Library](https://github.com/websockets/ws)

## 🐛 Troubleshooting

### WebSocket Connection Fails

- Ensure `PUBLIC_URL` is set correctly (must be `wss://` for ConversationRelay)
- Check that your server is publicly accessible
- Verify ngrok is running (for local dev)

### OpenAI Authentication Error

- Verify `OPENAI_API_KEY` is set correctly
- Check you have credits in your OpenAI account
- Ensure API key has access to Realtime API

### Twilio Webhook Errors

- Verify webhook URL is publicly accessible (test with curl)
- Check webhook URL format: `https://your-domain.com/voice-handler`
- View webhook logs in Twilio Console → Monitor → Logs → Errors

### Call Connects but No Audio

- Check WebSocket connection is established (see server logs)
- Verify OpenAI API key has Realtime API access
- Ensure system prompt is configured in `config/system-prompt.js`

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a pull request.

## 📄 License

MIT License - feel free to use this starter pack for any project!

## 💬 Support

- [Twilio Support](https://support.twilio.com/)
- [OpenAI Help Center](https://help.openai.com/)
- [GitHub Issues](https://github.com/YOUR_USERNAME/conversationrelay-starter-pack/issues)

---

Built with ❤️ using [Twilio ConversationRelay](https://www.twilio.com/docs/voice/conversationrelay) and [OpenAI Realtime API](https://platform.openai.com/docs/guides/realtime)
