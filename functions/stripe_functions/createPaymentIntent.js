const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const createPaymentIntent = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }
    const paymentIntent = await stripe.paymentIntents.create({
        amount: data.amount,
        currency: data.currency,
        capture_method: "manual",
    });

    return paymentIntent.client_secret;
});

module.exports = createPaymentIntent;
