const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const removePaymentMethod = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }

    try {
        stripe.paymentMethods.detach(data.paymentMethodId);
    } catch (error) {
        console.error("Stripe error:", error);
        throw new functions.https.HttpsError("unknown", `Error retrieving payment method: ${error.message}`);
    }
});

module.exports = removePaymentMethod;
