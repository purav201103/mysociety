import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

admin.initializeApp();

// Sends a notification when a new notice is created
export const onnoticecreated = onDocumentCreated(
  "notices/{noticeId}",
  (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.log("No data associated with the event");
      return;
    }
    const notice = snapshot.data();

    const payload = {
      notification: {
        title: "New Society Notice!",
        body: notice.title,
        sound: "default",
      },
      topic: "notices",
    };

    logger.log("Attempting to send notification for:", notice.title);

    return admin.messaging().send(payload)
      .then((response) => {
        logger.log("Successfully sent message:", response);
        return response;
      })
      .catch((error) => {
        logger.error("Error sending message:", error);
        return error;
      });
  },
);

// Sends a notification when a complaint status is updated
export const oncomplaintupdated = onDocumentUpdated(
  "complaints/{complaintId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (!beforeData || !afterData || beforeData.status === afterData.status) {
      logger.log("No status change, exiting function.");
      return null;
    }

    const residentUid = afterData.residentUid;
    if (!residentUid) {
      logger.error("Resident UID not found in complaint document.");
      return null;
    }

    const userDoc = await admin.firestore()
      .collection("users").doc(residentUid).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      logger.log("User does not have an FCM token.");
      return null;
    }

    const payload = {
      notification: {
        title: "Your Complaint Status is Updated!",
        body: `Your complaint "${afterData.title}" is now "${afterData.status}".`,
        sound: "default",
      },
    };

    logger.log(`Sending status update to resident ${residentUid}`);

    return admin.messaging().sendToDevice(fcmToken, payload);
  },
);

// Sends a notification when a booking status is updated
export const onbookingstatusupdated = onDocumentUpdated("bookings/{bookingId}", async (event) => {
  const beforeData = event.data?.before.data();
  const afterData = event.data?.after.data();

  // Only send if the status has changed from 'Pending'
  if (!beforeData || !afterData || beforeData.status !== "Pending" || afterData.status === "Pending") {
    logger.log("No relevant status change, exiting.");
    return null;
  }

  const residentUid = afterData.residentUid;
  const userDoc = await admin.firestore().collection("users").doc(residentUid).get();
  const fcmToken = userDoc.data()?.fcmToken;

  if (!fcmToken) {
    logger.log("User does not have an FCM token.");
    return null;
  }

  const payload = {
    notification: {
      title: `Booking ${afterData.status}!`,
      body: `Your booking for ${afterData.amenityName} on ${new Date(afterData.bookingDate.seconds * 1000).toLocaleDateString()} has been ${afterData.status}.`,
    },
  };

  logger.log(`Sending booking status update to resident ${residentUid}`);
  return admin.messaging().sendToDevice(fcmToken, payload);
});