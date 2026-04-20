const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin globally
// In production Vercel, set FIREBASE_SERVICE_ACCOUNT as a stringified JSON environment variable
if (!admin.apps.length) {
    try {
        if (process.env.FIREBASE_SERVICE_ACCOUNT) {
            const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount)
            });
        } else {
            console.warn("FIREBASE_SERVICE_ACCOUNT explicitly missing fallback to default.");
            admin.initializeApp();
        }
    } catch (e) {
        console.warn("Could not load FIREBASE_SERVICE_ACCOUNT env var properly.", e.message);
        admin.initializeApp();
    }
}

const db = admin.firestore();
const messaging = admin.messaging();

module.exports = async (req, res) => {
    // Enable CORS logic for Serverless Functions
    cors(req, res, async () => {
        if (req.method !== 'POST') {
            return res.status(405).json({ error: 'Method Not Allowed' });
        }

        try {
            const { userId, serviceType, address, notes, amount } = req.body;

            if (!userId || !serviceType || !address) {
                return res.status(400).json({ error: 'Missing required parameters' });
            }

            // 1. Create original booking directly in Firestore
            const newBookingRef = db.collection('bookings').doc();
            const bookingData = {
                userId,
                serviceType,
                address,
                notes: notes || '',
                amount: amount || 0,
                status: 'pending',
                workerName: '',
                workerId: '',
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            };

            await newBookingRef.set(bookingData);

            // 2. Auto-Assign Mock logic
            // Simulate the backend finding an available worker and updating the booking
            const updatedData = {
                status: 'inProgress',
                workerId: 'mock_worker_001',
                workerName: 'Rajan Kumar'
            };

            await newBookingRef.update(updatedData);

            // 3. Find User's FCM Token to Dispatch Push Notification
            const userDoc = await db.collection('users').doc(userId).get();
            if (userDoc.exists) {
                const userData = userDoc.data();
                if (userData.fcmToken) {
                    const message = {
                        notification: {
                            title: 'Worker Assigned! 🚙',
                            body: `Rajan Kumar has been assigned to your ${serviceType} request and is on their way.`
                        },
                        data: {
                            bookingId: newBookingRef.id,
                            click_action: 'FLUTTER_NOTIFICATION_CLICK'
                        },
                        token: userData.fcmToken
                    };

                    await messaging.send(message);
                    console.log('✅ FCM Notification sent to token:', userData.fcmToken);
                }
            }

            // Return success payload to Flutter
            return res.status(200).json({ 
                success: true, 
                bookingId: newBookingRef.id,
                message: 'Booking created and assigned' 
            });

        } catch (error) {
            console.error('❌ Error creating booking:', error);
            return res.status(500).json({ error: error.message });
        }
    });
};
