import { Client, Databases, Query } from "node-appwrite";

export default async ({ req, res, log, error }) => {
  try {
    const client = new Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("67ddfedd00142dbfb48e")
      .setKey(req.headers['x-appwrite-key']);

    const databases = new Databases(client);

    // Get the next 7 days (today + 6 more days)
    const today = new Date();
    const weekDates = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      weekDates.push(date.toISOString().split("T")[0]); // "YYYY-MM-DD"
    }

    log(`Checking for bookings for the week: ${weekDates.join(', ')}`);

    // Query both collections for the entire week
    const allBookingsThisWeek = [];

    for (const dateStr of weekDates) {
      const [emwResults, consumerResults] = await Promise.all([
        databases.listDocuments(
          "67e640bd00005fc192ff",
          "67fd925a0037a0a4016c", // EMW collection
          [Query.startsWith("startDate", dateStr)]
        ),
        databases.listDocuments(
          "67e640bd00005fc192ff", 
          "680981c7001a14ab71f4", // Consumer collection  
          [Query.startsWith("workDate", dateStr)]
        ),
      ]);

      // Add date info to each booking for the notification message
      const emwBookingsWithDate = emwResults.documents.map(booking => ({
        ...booking,
        workDateStr: dateStr,
        collectionType: 'EMW'
      }));

      const consumerBookingsWithDate = consumerResults.documents.map(booking => ({
        ...booking,
        workDateStr: dateStr,
        collectionType: 'Consumer'
      }));

      allBookingsThisWeek.push(...emwBookingsWithDate, ...consumerBookingsWithDate);
    }

    log(`Found ${allBookingsThisWeek.length} total bookings for this week`);

    // Send notifications for each booking with date info
    for (const booking of allBookingsThisWeek) {
      const workDate = new Date(booking.workDateStr);
      const dateLabel = getDateLabel(workDate);
      
      await sendOneSignalNotification({
        title: `🚧 Work Scheduled!`,
        message: `${booking.partyName} at ${booking.workLocation} - ${dateLabel} (${booking.workDateStr})`,
        organizationId: booking.organizationId,
      });

      log(`Notification sent for: ${booking.partyName} on ${booking.workDateStr}`);
    }

    return res.json({
      success: true,
      totalBookings: allBookingsThisWeek.length,
      datesChecked: weekDates,
      bookingsByDate: weekDates.map(date => ({
        date,
        count: allBookingsThisWeek.filter(b => b.workDateStr === date).length
      }))
    });
  } catch (err) {
    error("Function failed:", err.message);
    return res.json({ error: err.message }, 500);
  }
};

// Helper function to get user-friendly date labels
function getDateLabel(date) {
  const today = new Date();
  const tomorrow = new Date(today);
  tomorrow.setDate(today.getDate() + 1);
  
  if (date.toDateString() === today.toDateString()) {
    return "Today";
  } else if (date.toDateString() === tomorrow.toDateString()) {
    return "Tomorrow";
  } else {
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayNames[date.getDay()];
  }
}

async function sendOneSignalNotification({ title, message, organizationId }) {
  const response = await fetch("https://onesignal.com/api/v1/notifications", {
    method: "POST",
    headers: {
      Authorization: `Basic os_v2_app_3co7hqq5ajgdnf2vc2v7753gcjandhojm2fu7o4ylnbw5vcqvigmbdth2zejqmawgyjavc3sbac2z2tbthldg2cv4ims3cl6xgxk5va`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      app_id: 'd89df3c2-1d02-4c36-9755-16abfff76612',
      filters: [
        {
          field: "tag",
          key: "organizationId",
          relation: "=",
          value: organizationId,
        },
      ],
      contents: { en: message },
      headings: { en: title },
      priority: 10,
    }),
  });

  return response.json();
}
