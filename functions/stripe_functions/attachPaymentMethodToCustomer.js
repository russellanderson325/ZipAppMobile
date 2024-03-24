const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const attachPaymentMethodToCustomer = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }
    const paymentMethod = await stripe.paymentMethods.attach(
        data.paymentMethodId,
        {
            customer: data.customerId,
        },
    );
    return paymentMethod;
});

module.exports = attachPaymentMethodToCustomer;
