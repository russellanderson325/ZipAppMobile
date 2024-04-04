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
        console.log("Capturing payment intent with ID", data.paymentIntentId);
        const captureResponse = await stripe.paymentIntents.capture(data.paymentIntentId);
        return captureResponse;
    } catch (error) {
        console.error("Stripe error:", error);
        throw new functions.https.HttpsError("internal", "Stripe error", error);
    }
});

module.exports = capturePaymentIntent;
