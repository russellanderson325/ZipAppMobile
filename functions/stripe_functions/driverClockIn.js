const functions = require("firebase-functions");
const admin = require("firebase-admin");

const driverClockIn = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }

    const {daysOfWeek, isWorking, driveruid, shiftuid} = data;

    if (isWorking) {
        return {result: false, message: "Driver already clocked in", isWorking};
    }

    const currentTime = new Date();
    if (!daysOfWeek.includes(currentTime.getDay())) {
        return {result: false, override: true, message: "Driver not scheduled today"};
    }

    const shiftRef = await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).get();

    if (!shiftRef.exists) {
        await createShift(driveruid, shiftuid, currentTime);
        return {result: false, override: true, message: "Driver not scheduled", isWorking: false};
    }

    const shift = shiftRef.data();
    if (currentTime.getTime() < shift.startTime.toDate().getTime() - 600000) {
        return {result: false, override: true, message: "Too early for scheduled time"};
    }

    try {
        await updateShiftAndDriverStatus(driveruid, shiftuid, currentTime);
        console.log("Capturing payment intent with ID", data.paymentIntentId);
        return {success: true, message: "Clock in successful"};
    } catch (error) {
        console.error("Stripe error:", error);
        return {success: false, response: error};
    }
});

/**
 * Create a new shift for the driver
 * @param {string} driveruid - The driver's uid
 * @param {string} shiftuid - The shift's uid
 * @param {Date} currentTime - The current time
 * @return {Promise<void>}
 */
async function createShift(driveruid, shiftuid, currentTime) {
    const adjustedTime = new Date(currentTime);
    adjustedTime.setMinutes(currentTime.getMinutes() - 30);
    await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).set({
            shiftStart: adjustedTime,
            shiftEnd: adjustedTime,
            startTime: adjustedTime,
            endTime: adjustedTime,
            totalShiftTime: 0,
            totalBreakTime: 0,
            overrideNeeded: true,
        });
}

/**
 * Update the driver's shift and status
 * @param {String} driveruid
 * @param {String} shiftuid
 * @param {Date} currentTime
 * @return {Promise<void>}
 */
async function updateShiftAndDriverStatus(driveruid, shiftuid, currentTime) {
    await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).update({
            totalBreakTime: 0,
            totalShiftTime: 0,
            shiftStart: currentTime,
            overrideNeeded: false,
        });

    await admin.firestore().collection("drivers").doc(driveruid).update({
        isWorking: true,
        isAvailable: true,
        isOnBreak: false,
    });
}

module.exports = driverClockIn;
