const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.sendNotificationToAllUsers = functions.firestore.document('Comics/{ComicsId}')
    .onCreate(async (snapshot, context) => {
      const storyTitle = snapshot.data().title;

      const payload = {
        notification: {
          title: 'Truyện mới',
          body: `Truyện mới: ${storyTitle}`,
        }
      };

      const allUsersSnapshot = await db.collection('User').where('Status', '==', false).get();

      const tokens = [];
      allUsersSnapshot.forEach(user => {
        const userDoc = user.data();
        if (userDoc.tokens && userDoc.tokens.length > 0) {
          tokens.push(...userDoc.tokens);
        }
      });

      if (tokens.length > 0) {
        await admin.messaging().send(tokens, payload);
      }
    });
    