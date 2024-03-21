const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Import the functions from the other files
const getPaymentMethodDetails = require("./stripe_functions/getPaymentMethodDetails");
const removePaymentMethod = require("./stripe_functions/removePaymentMethod");

// Export the functions
exports.getPaymentMethodDetails = getPaymentMethodDetails;
exports.removePaymentMethod = removePaymentMethod;
