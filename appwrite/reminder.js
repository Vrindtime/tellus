import { Client, Databases, Query } from 'node-appwrite';

export default async ({ req, res, log, error }) => {
  try {
    // Initialize Appwrite
    const client = new Client()
      .setEndpoint(process.env.APPWRITE_FUNCTION_ENDPOINT)
      .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
      .setKey(process.env.APPWRITE_API_KEY);
    
    const databases = new Databases(client);
    
    // Get tomorrow's date
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tomorrowStr = tomorrow.toISOString().split('T')[0];
    
    log(`Checking for bookings on: ${tomorrowStr}`);
    
    // Query bookings for tomorrow
    const bookings = await databases.listDocuments(
      process.env.DATABASE_ID,
      process.env.BOOKINGS_COLLECTION_ID,
      [Query.equal('startDate', tomorrowStr)]
    );
    
    log(`Found ${bookings.documents.length} bookings for tomorrow`);
    
    // Send notifications for each booking
    for (const booking of bookings.documents) {
      await sendOneSignalNotification({
        title: '🚧 Work Tomorrow!',
        message: `${booking.clientName} at ${booking.workLocation}`,
        organizationId: booking.organizationId
      });
      
      log(`Notification sent for: ${booking.clientName}`);
    }
    
    return res.json({ 
      success: true, 
      bookingsFound: bookings.documents.length 
    });
    
  } catch (err) {
    error('Function failed:', err.message);
    return res.json({ error: err.message }, 500);
  }
};

async function sendOneSignalNotification({ title, message, organizationId }) {
  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${process.env.ONESIGNAL_REST_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      app_id: process.env.ONESIGNAL_APP_ID,
      filters: [
        { field: 'tag', key: 'organizationId', relation: '=', value: organizationId }
      ],
      contents: { en: message },
      headings: { en: title },
      priority: 10
    })
  });
  
  return response.json();
}
