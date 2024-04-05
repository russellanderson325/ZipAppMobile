const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const capturePaymentIntent = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }

    try {
        const captureResponse = await stripe.paymentIntents.capture(data.paymentIntentId);
        console.log("Capturing payment intent with ID", data.paymentIntentId);
        return {success: true, response: captureResponse};
    } catch (error) {
        console.error("Stripe error:", error);
        return {success: false, response: error};
    }
});

module.exports = capturePaymentIntent;
