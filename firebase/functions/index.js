const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

/**
 * Sends FCM when an in-app notification is created, mirroring chat delivery rules.
 */
exports.onUserNotificationCreated = onDocumentCreated(
  'users/{userId}/notifications/{notificationId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const recipientUid = event.params.userId;
    const type = data.type || '';
    const activityId = data.activityId || '';

    const userSnap = await getFirestore().collection('users').doc(recipientUid).get();
    const user = userSnap.data() || {};

    if (type === 'chat') {
      if (user.notifyChat === false) return;
      const muted = Array.isArray(user.mutedActivityIds)
        ? user.mutedActivityIds.includes(activityId)
        : false;
      if (muted) return;
    }

    const tokens = Array.isArray(user.fcmTokens) ? user.fcmTokens.filter(Boolean) : [];
    if (tokens.length === 0) return;

    const title = data.activityTitle || 'MeetRadius';
    const body = data.body || 'You have a new notification';

    await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: {
        type,
        activityId,
        openChat: data.openChat ? 'true' : 'false',
      },
    });
  },
);
