const OpenAI = require('openai');
const systemPrompt = require('../config/system-prompt');
const tools = require('./tools');

/**
 * WebSocket Handler - Manages ConversationRelay WebSocket connection
 *
 * This handler manages the bidirectional streaming between:
 * - Twilio (caller's audio)
 * - OpenAI Realtime API (AI conversation)
 *
 * @param {WebSocket} ws - WebSocket connection
 * @param {Object} config - Configuration object
 */
function websocketHandler(ws, config) {
  const { streamSid, openaiApiKey, twilioClient } = config;

  console.log(`📞 ConversationRelay connected: ${streamSid}`);

  // TODO: Step 5 - Initialize OpenAI Realtime API connection
  // const openai = new OpenAI({ apiKey: openaiApiKey });
  // const openaiWs = openai.realtime.connect();

  // TODO: Step 6 - Set up message routing
  // Route messages between Twilio and OpenAI

  // Handle incoming messages from Twilio
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);

      // TODO: Handle different message types from Twilio
      // - 'start': Connection established
      // - 'media': Audio data from caller
      // - 'stop': Call ended

      console.log('📥 Twilio message:', data.event);

      // TODO: Forward audio to OpenAI
      // TODO: Send events to OpenAI (e.g., DTMF, interruptions)

    } catch (error) {
      console.error('❌ Error parsing message:', error);
    }
  });

  // TODO: Handle messages from OpenAI
  // openaiWs.on('message', (message) => {
  //   // Forward AI responses back to Twilio
  //   // Handle function calls
  //   // Manage conversation state
  // });

  // Handle connection close
  ws.on('close', () => {
    console.log(`📞 ConversationRelay disconnected: ${streamSid}`);
    // TODO: Close OpenAI connection
    // TODO: Clean up resources
  });

  // Handle errors
  ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error);
  });

  // TODO: Step 7 - Send initial system prompt to OpenAI
  // Configure the AI's personality and behavior

  // TODO: Step 8 - Configure function calling / tools
  // Enable the AI to call external functions (e.g., database lookups, API calls)
}

module.exports = websocketHandler;
