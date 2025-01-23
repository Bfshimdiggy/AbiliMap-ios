const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Function to assign admin role to a user by email
exports.setAdminClaim = functions.https.onCall(async (data, context) => {
  // Only allow authenticated users with the 'admin' claim to assign admin rights
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can assign admin roles.');
  }

  const email = data.email;

  try {
    // Set a custom claim to mark the user as an admin
    await admin.auth().setCustomUserClaims(email, { admin: true });

    // Optionally, update the user's data in Firestore
    await admin.firestore().collection('users').doc(email).set({
      isAdmin: true
    }, { merge: true });

    return { message: `Admin rights granted to ${email}` };
  } catch (error) {
    throw new functions.https.HttpsError('unknown', error.message);
  }
});

// Function to get user details
exports.getUserDetails = functions.https.onCall(async (data, context) => {
  const email = data.email;

  try {
    const userRecord = await admin.auth().getUserByEmail(email);
    return {
      uid: userRecord.uid,
      email: userRecord.email,
      displayName: userRecord.displayName,
    };
  } catch (error) {
    throw new functions.https.HttpsError('unknown', error.message);
  }
});
