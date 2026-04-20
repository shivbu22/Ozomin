const express = require('express');
const cors = require('cors');
const bookingsHandler = require('./api/bookings');

const app = express();
app.disable('x-powered-by'); // Security header fix
app.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    next();
});
app.use(cors());
app.use(express.json());

// Bind the Vercel serverless function to an express route for local testing
app.post('/api/bookings', bookingsHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Local dev server running on http://localhost:${PORT}`);
    console.log(`Testing endpoint available at: POST http://localhost:${PORT}/api/bookings`);
});
