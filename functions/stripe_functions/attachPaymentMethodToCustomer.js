const functions = require("firebase-functions");
const secretKey = functions.config().stripe.secret;
const stripe = require("stripe")(secretKey);

const attachPaymentMethodToCustomer = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "The function must be called while authenticated.",
        );
    }
    try {
        const paymentMethod = await stripe.paymentMethods.attach(
            data.paymentMethodId,
            {
                customer: data.customerId,
            },
        );
        console.log("Payment method attached to customer", paymentMethod.id);
        return {success: true, response: paymentMethod};
    } catch (error) {
        console.error("Stripe error:", error);
        return {success: false, response: error};
    }
});

module.exports = attachPaymentMethodToCustomer;
