const functions = require("firebase-functions");
const admin = require("firebase-admin");

/**
 * Cloud function to end a break for a driver.
 */
const driverEndBreak = functions.https.onCall(async (data, context) => {
    const {driveruid, shiftuid} = data;
    const currentTime = new Date();

    try {
        const driverDoc = await admin.firestore().collection("drivers").doc(driveruid).get();

        if (!driverDoc.exists) {
            return {success: false, response: "No Driver Found"};
        }

        const shiftDoc = await admin.firestore().collection("drivers").doc(driveruid)
            .collection("shifts").doc(shiftuid).get();

        const shift = shiftDoc.data();
        const breakTime = currentTime.getTime() - shift.breakStart.toDate().getTime();

        await admin.firestore().collection("drivers").doc(driveruid)
            .collection("shifts").doc(shiftuid).update({
                breakEnd: currentTime,
                totalBreakTime: admin.firestore.FieldValue.increment(breakTime),
            });

        await admin.firestore().collection("drivers").doc(driveruid).update({
            "isOnBreak": false,
            "isAvailable": true,
            "isWorking": false,
        });

        return {success: true, response: "Break has ended successfully"};
    } catch (error) {
        console.error("Error ending break:", error);
        return {success: false, response: "An error occurred"};
    }
});

module.exports = driverEndBreak;
