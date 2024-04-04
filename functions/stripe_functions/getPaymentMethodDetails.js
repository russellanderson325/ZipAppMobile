const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const getPaymentMethodDetails = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }

    try {
        const paymentMethodId = data.paymentMethodId; // Expect "paymentMethodId" to be passed in the function call
        const paymentMethod = await stripe.paymentMethods.retrieve(paymentMethodId);
        return {success: true, response: paymentMethod.card};
    } catch (error) {
        console.error("Stripe error:", error);
        return {success: false, response: error};
    }
});

module.exports = getPaymentMethodDetails;
