const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Import the functions from the other files
const getPaymentMethodDetails = require("./stripe_functions/getPaymentMethodDetails");

// Export the functions
exports.getPaymentMethodDetails = getPaymentMethodDetails;
