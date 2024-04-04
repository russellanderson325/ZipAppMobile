const functions = require("firebase-functions");
const admin = require("firebase-admin");

/*
* Cloud function to start a break for a driver.
*/
const driverStartBreak = functions.https.onCall(async (data, context) => {
    const {driveruid, shiftuid} = data;
    const currentTime = new Date();

    const driverDoc = await admin.firestore().collection("drivers").doc(driveruid).get();
    if (!driverDoc.exists) return {success: false, response: "No Driver Found"};

    try {
        await admin.firestore().collection("drivers").doc(driveruid)
            .collection("shifts").doc(shiftuid).update({
                "breakStart": currentTime,
            });

        await admin.firestore().collection("drivers").doc(driveruid).update({
            "isOnBreak": true,
            "isAvailable": false,
            "isWorking": false,
        });

        return {success: true, response: "Break has started successfully"};
    } catch (error) {
        console.error("Error starting break:", error);
        return {success: false, response: "An error occurred"};
    }
});

module.exports = driverStartBreak;
