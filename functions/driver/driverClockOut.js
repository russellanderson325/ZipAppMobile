const functions = require("firebase-functions");
const admin = require("firebase-admin");
const db = admin.firestore();

const driverClockOut = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }

    const {driveruid, shiftuid} = data;
    const currentTime = new Date();
    let message = "";
    let result = false;

    try {
        const driverRef = await db.collection("drivers").doc(driveruid).get();

        if (!driverRef.exists) {
            throw new Error("No Driver Found");
        }

        const shiftRef = await driverRef.ref.collection("shifts").doc(shiftuid).get();

        if (!shiftRef.exists) {
            // create new shift
            await shiftRef.ref.set({
                shiftStart: currentTime,
                shiftEnd: currentTime,
                totalShiftTime: 0,
                totalBreakTime: 0,
                shiftFinished: true,
            });
            result = false;
            message = "Error: No shift found. Created new shift.";
        } else {
            const shiftData = shiftRef.data();
            const shiftDurationMs = currentTime - shiftData.shiftStart.toDate() - shiftData.totalBreakTime;
            const totalMinutes = Math.round(shiftDurationMs / 60000);
            const hours = Math.floor(totalMinutes / 60);
            const minutes = totalMinutes % 60;

            await shiftRef.ref.update({
                shiftEnd: currentTime,
                totalShiftTime: shiftDurationMs,
                totalBreakTime: 0,
                shiftFinished: true,
            });

            const totalHoursSoFar = hours + minutes / 60;
            await driverRef.ref.update({
                isWorking: false,
                isAvailable: false,
                isOnBreak: false,
                totalHoursWorked: admin.firestore.FieldValue.increment(totalHoursSoFar),
            });

            result = true;
            message = "Driver is successfully clocked out";
        }
    } catch (error) {
        console.error(error);
        message = error.message;
    }

    return {success: result, response: message};
});

module.exports = driverClockOut;
