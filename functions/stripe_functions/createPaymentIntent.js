const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const createPaymentIntent = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }

    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount: data.amount,
            currency: data.currency,
            capture_method: "manual",
        });
        console.log("Payment intent created with ID", paymentIntent.id);
        return {success: true, response: paymentIntent};
    } catch (error) {
        console.error("Stripe error:", error);
        return {success: false, response: error};
    }
});

module.exports = createPaymentIntent;
