const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const cancelPaymentIntent = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }

    try {
        const canceledIntent = await stripe.paymentIntents.cancel(data["paymentIntentId"]);
        console.log("Payment Intent was canceled successfully:", canceledIntent);
    } catch (error) {
        console.error("Error canceling the Payment Intent:", error);
    }
});

module.exports = cancelPaymentIntent;
