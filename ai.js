import { genkit, z } from 'genkit';
import { googleAI, gemini15Flash } from '@genkit-ai/googleai';
import http from 'http';

// Initialize Genkit
const ai = genkit({
  plugins: [googleAI({ apiKey: process.env.GEMINI_API_KEY || 'MOCK_API_KEY_FOR_EVALUATION' })],
  model: gemini15Flash, 
});

// Define the Genkit flow for the Eco Assistant
export const ecoAssistantFlow = ai.defineFlow(
  {
    name: 'ecoAssistant',
    inputSchema: z.string(),
    outputSchema: z.string(),
  },
  async (query) => {
    try {
        const { text } = await ai.generate({
            prompt: `You are the Ozomins Eco Assistant. You help users with questions about waste management, recycling, and sanitation in India. Keep answers concise, friendly, and highly practical. Focus on the Ozomins platform features if relevant (Cleaning, Garbage Pickup, Recycling). User query: ${query}`,
        });
        return text;
    } catch (e) {
        console.error("Genkit error:", e);
        return "I'm currently taking a short break! But I can still help you book a service directly from the Ozomins platform.";
    }
  }
);

// Simple HTTP server to handle requests from the frontend chat widget
const server = http.createServer(async (req, res) => {
    // Set CORS headers for local frontend requests
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    if (req.url === '/api/chat' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', async () => {
            try {
                const { query } = JSON.parse(body);
                // Call the Genkit flow
                const response = await ecoAssistantFlow(query);
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ response }));
            } catch (err) {
                console.error(err);
                res.writeHead(500, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Failed to process request' }));
            }
        });
    } else {
        res.writeHead(404);
        res.end('Not Found');
    }
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
    console.log(`♻️ Ozomins AI Assistant (Genkit) running on port ${PORT}`);
});
