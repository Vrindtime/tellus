// import { Client, Databases, Query } from "node-appwrite";

// export default async ({ req, res, log, error }) => {
//   try {
//     // Initialize Appwrite
//     const client = new Client()
//       .setEndpoint("https://cloud.appwrite.io/v1")
//       .setProject("67ddfedd00142dbfb48e")
//       .setKey(process.env.APPWRITE_API_KEY);

//     const databases = new Databases(client);

//     // Get tomorrow's date
//     const tomorrow = new Date();
//     tomorrow.setDate(tomorrow.getDate() + 1);
//     const tomorrowStr = tomorrow.toISOString().split("T")[0];

//     log(`Checking for bookings on: ${tomorrowStr}`);

//     // Query BOTH collections for tomorrow's bookings
//     const [collection1Results, collection2Results] = await Promise.all([
//       databases.listDocuments(
//         "67e640bd00005fc192ff",
//         "67fd925a0037a0a4016c", // First collection with startDate EMW
//         [Query.equal("startDate", tomorrowStr)]
//       ),
//       databases.listDocuments(
//         "67e640bd00005fc192ff",
//         "680981c7001a14ab71f4", // Second collection with startDateConsumer
//         [Query.equal("startDate", tomorrowStr)]
//       ),
//     ]);

//     // Combine bookings from both collections
//     const allBookings = [
//       ...collection1Results.documents,
//       ...collection2Results.documents,
//     ];

//     log(`Found ${allBookings.length} total bookings for tomorrow`);
//     log(`Collection 1: ${collection1Results.documents.length} bookings`);
//     log(`Collection 2: ${collection2Results.documents.length} bookings`);

//     // Send notifications for each booking
//     for (const booking of allBookings) {
//       await sendOneSignalNotification({
//         title: "🚧 Work Tomorrow!",
//         message: `${booking.partyName} at ${booking.workLocation}`,
//         organizationId: booking.organizationId,
//       });

//       log(`Notification sent for: ${booking.partyName}`);
//     }

//     return res.json({
//       success: true,
//       bookingsFound: bookings.documents.length,
//     });
//   } catch (err) {
//     error("Function failed:", err.message);
//     return res.json({ error: err.message }, 500);
//   }
// };

// async function sendOneSignalNotification({ title, message, organizationId }) {
//   const response = await fetch("https://onesignal.com/api/v1/notifications", {
//     method: "POST",
//     headers: {
//       Authorization: `Basic os_v2_app_3co7hqq5ajgdnf2vc2v7753gcjandhojm2fu7o4ylnbw5vcqvigmbdth2zejqmawgyjavc3sbac2z2tbthldg2cv4ims3cl6xgxk5va`,
//       "Content-Type": "application/json",
//     },
//     body: JSON.stringify({
//       app_id: 'd89df3c2-1d02-4c36-9755-16abfff76612',
//       filters: [
//         {
//           field: "tag",
//           key: "organizationId",
//           relation: "=",
//           value: organizationId,
//         },
//       ],
//       contents: { en: message },
//       headings: { en: title },
//       priority: 10,
//     }),
//   });

//   return response.json();
// }

import { Client, Databases } from 'node-appwrite';

export default async ({ req, res, log, error }) => {
  log('Testing database permissions...');
  
  try {
    const client = new Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('67ddfedd00142dbfb48e')
      .setKey('68b257e10026f7c97132'); // Your API key

    const databases = new Databases(client);
    
    log('Client initialized, attempting database query...');

    // Test simple database query - list first 3 documents
    const result = await databases.listDocuments(
      '67e640bd00005fc192ff',    // Your database ID
      '67fd925a0037a0a4016c',   // Your first collection ID (EMW)
      [],                       // No queries
      3                         // Limit to 3 documents
    );

    log(`Successfully found ${result.documents.length} documents`);
    
    return res.json({ 
      success: true, 
      documentsFound: result.documents.length,
      message: 'Database permissions working!'
    });
    
  } catch (err) {
    error('Database query failed:', err.message);
    return res.json({ 
      error: err.message,
      success: false 
    }, 500);
  }
};
