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

    // Extracting the last 4 digits and brand from the payment method
    const last4 = paymentMethod.card.last4;
    const brand = paymentMethod.card.brand;

    // Optionally, store these details in Firestore or return them to the client
    return {last4, brand};
  } catch (error) {
    console.error("Stripe error:", error);
    throw new functions.https.HttpsError("unknown", `Error retrieving payment method: ${error.message}`);
  }
});

module.exports = getPaymentMethodDetails;
