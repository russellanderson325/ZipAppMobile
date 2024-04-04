const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Import the functions from the other files
const getPaymentMethodDetails = require("./stripe_functions/getPaymentMethodDetails");
const removePaymentMethod = require("./stripe_functions/removePaymentMethod");
const attachPaymentMethodToCustomer = require("./stripe_functions/attachPaymentMethodToCustomer");
const createPaymentIntent = require("./stripe_functions/createPaymentIntent");
const capturePaymentIntent = require("./stripe_functions/capturePaymentIntent");
const driverClockOut = require("./stripe_functions/driverClockOut");

// Export the functions
exports.getPaymentMethodDetails = getPaymentMethodDetails;
exports.removePaymentMethod = removePaymentMethod;
exports.attachPaymentMethodToCustomer = attachPaymentMethodToCustomer;
exports.createPaymentIntent = createPaymentIntent;
exports.capturePaymentIntent = capturePaymentIntent;
exports.driverClockOut = driverClockOut;
