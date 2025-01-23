const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createIssue = functions.https.onRequest(async (req, res) => {
  // Extract data from the request body
  const {userId, issueDescription, affectedDescription} = req.body;

  try {
    // Create a new issue in the Firestore database
    const issueRef = await admin.firestore().collection("issues").add({
      userId: userId,
      issueDescription: issueDescription,
      affectedDescription: affectedDescription,
      status: "Pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Return the new issue number (ID) to the client
    res.status(201).json({
      issueNumber: issueRef.id,
      status: "Pending",
    });
  } catch (error) {
    console.error("Error creating issue: ", error);
    res.status(500).json({error: "Failed to create issue"});
  }
});

exports.getIssue = functions.https.onRequest(async (req, res) => {
  const issueNumber = req.query.issueNumber;

  try {
    // Fetch the issue from Firestore
    const issueDoc = await admin.firestore()
        .collection("issues")
        .doc(issueNumber)
        .get();

    if (!issueDoc.exists) {
      res.status(404).json({error: "Issue not found"});
      return;
    }

    // Return the issue details
    res.status(200).json(issueDoc.data());
  } catch (error) {
    console.error("Error fetching issue: ", error);
    res.status(500).json({error: "Failed to fetch issue"});
  }
});
