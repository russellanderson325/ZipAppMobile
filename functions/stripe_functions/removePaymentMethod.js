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
        console.log("Payment method removed with ID", data.paymentMethodId);
        return {success: true, response: "Payment method removed successfully."};
    } catch (error) {
        console.error("Stripe error:", error);
        return {success: false, response: error};
    }
});

module.exports = removePaymentMethod;
