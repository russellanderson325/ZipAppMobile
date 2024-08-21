/// NOTE TO FUTURE DEVELOPERS: This is an old file from past years that contains some still existing firebase functions.
/// A few of the functions here were phased out in favor of the new functions split up in the driver and stripe_functions
/// directories. AGAIN, SOME OF THESE ARE STILL IN USE ON FIREBASE. DO NOT DELETE THIS FILE.
/// IN THE FUTURE YOU SHOULD WORK ON PHASING OUT THE FUNCTIONS IN THIS FILE AND MOVING THEM TO THE NEW FUNCTIONS IN THEIR OWN FILES.
/// THIS WAS SIGNED BY JORDYN LEWIS 04/26/2024
/// READ ABOVE NOTE BEFORE CONTINUING
/// ###############################################################################

/// PLEASE READ THIS FILE THOROUGHLY

//import * as functions from "firebase-functions";
const functions = require('firebase-functions');
const admin = require("firebase-admin");
const app = require("express")();
//const bodyParser = require("body-parser");
//const { resolve } = require("path");
//const session = require("express-session");
const https = require('https');
//const info = functions.config().info;
//const router = express.Router();
admin.initializeApp(functions.config().firebase);


const stripe = require('stripe')(functions.config().stripe.testkey);
//router.post('/accounts', admin, createExpressAccount);
// //Ability ot log to console
// const { Logging } = require('@google-cloud/logging');

// // Instantiates a client
// const logging = new Logging();


//const app = express();
// app.get('/', (req, res) => res.status(200).send('Hey there!'))

// // Use JSON parser for all non-webhook routes
// app.use(async (req, res) => {
//   if (req.originalUrl === "/webhook") {
//     next();
//   } else { 
//     bodyParser.json()(req, res, next);
//   }
// });


// app.get("/", (req, res) => {
//   const path = resolve(process.env.STATIC_DIR + "/index.html");
//   res.sendFile(path);
// });

// app.post("/onboard-user", async (req, res) => {
//   try {
//     const account = await stripe.accounts.create({type: "express"});
//     req.session.accountID = account.id;

//     const origin = `${req.headers.origin}`;
//     const accountLinks = await stripe.accountLinks.create({
//       type: "account_onboarding",
//       account: account.id,
//       refresh_url: `${origin}/onboard-user/refresh`,
//       return_url: `${origin}/success.html`,
//     });
//     res.send({url: accountLinks});
//   } catch (err) {
//     res.status(500).send({
//       error: err.message
//     });
//   }
// });


// app.get("/onboard-user/refresh", async (req, res) => {
//   if (!req.session.accountID) {
//     res.redirect("/");
//     return;
//   }
//   try {
//     const {accountID} = req.session;
//     const origin = `${req.secure ? "https://" : "https://"}${req.headers.host}`;
    
//     const accountLinks = await stripe.accountLinks.create({
//       type: "account_onboarding",
//       account: accountID,
//       refresh_url: `${origin}/onboard-user/refresh`,
//       return_url: `${origin}/success.html`,
//     });
//     res.redirect(accountLinks);
//   } catch (err) {
//     res.status(500).send({
//       error: err.message
//     });
//   }
// });

// exports.app = functions.https.onRequest((req, res) => {
  
//     // prepend '/' to keep query params if any
  
//   return app(req, res)
// })

// module.exports = {
//   app
// }
// app.use(bodyParser.urlencoded({ extended: true }));
// app.use(bodyParser.json());

exports.createExpressAccount = functions.https.onCall(async(req, res) => {
    const acc = await stripe.accounts.create({
      type: 'express',
      
    });
    const data = await acc.json();
    data.body = JSON.parse(data.body);
    return data;
    //const account = await stripe.accounts.create({type: 'express'});
    // app.post("/onboard-user", function onboardExpressUser (req,res){

    //   stripe.accounts.create({
    //     type: 'express',
        
    //   }, function(err, account) {
    //         if(err) {
    //         return res.send(JSON.stringify(err));
    //       }    
    //       res.send(account);
    //   });
    // });
  });

 
    //const origin = 
    //const pathname = '/onboard-user';
    //let data = '';

    // const accountLinkURL = await stripe.accountLinks.create({
    //   type: "account_onboarding",
    //   account: account.id,
    //   refresh_url: `${origin}/onboard-user/refresh`,
    //   return_url: `${origin}/success.html`,
    // }).then((link: { url: any; })=>link.url);
    
  


// exports.createStripeCustomer = functions.auth.user().onCreate(async (user) => {
//   const customer = await stripe.customers.create({ email: user.email });
//   const intent = await stripe.setupIntents.create({
//     customer: customer.id,
//   });
//   await admin.firestore().collection('stripe_customers').doc(user.uid).set({
//     customer_id: customer.id,
//     setup_secret: intent.client_secret,
//     intent_id: intent.id,
//   });
//   return;
// });

// //Delete payment methods
// //Look at Stripe docs - Detach payment method from customer
// exports.deletePaymentMethod = functions.firestore
// .document('/stripe_customers/{userId}/payment_methods/{pushId}')
// .onDelete(async (snap, context) => {
//   try {
//     const paymentMethodId = snap.data().id;
//     const paymentMethod = await stripe.paymentMethods.detach(
//       paymentMethodId
//     );
//     return;
//   }
//   catch (error) {
//     await snap.ref.set({ error: userFacingMessage(error) }, { merge: true });
//   //  await reportError(error, { user: context.params.userId });
//   }
// });
// /**
//  * When adding the payment method ID on the client,
//  * this function is triggered to retrieve the payment method details.
//  */
// exports.addPaymentMethodDetails = functions.firestore
//   .document('/stripe_customers/{userId}/payment_methods/{pushId}')
//   .onCreate(async (snap, context) => {
//     try {
//       //Get ID of payment method
//       const paymentMethodId = snap.data().id;

//       //get customerId and client secret
//       const snapshot = await admin.firestore().collection("stripe_customers").doc(context.params.userId).get();
//       const customerId = snapshot.data().customer_id;
//       const client_secret = snapshot.data().setup_secret;
//       const intent_id = snapshot.data().intent_id;

//       //CONFIRM setupIntent and attach paymentMethod ID
//       const setupIntent = await stripe.setupIntents.confirm(intent_id, {payment_method: paymentMethodId})

//      //retrieve payment method and store in firebase
//       const paymentMethod = await stripe.paymentMethods.retrieve(paymentMethodId);

//       await snap.ref.collection('payment').doc('valid_check').set(paymentMethod); //this is necessary to validate if paymnet method has been attached
//       await snap.ref.set(paymentMethod);
//       // Create a new SetupIntent so the customer can add a new method next time.
//       const newIntent = await stripe.setupIntents.create({
//         customer: paymentMethod.customer,
//       });
//       await snap.ref.parent.parent.set(
//         {
//           setup_secret: newIntent.client_secret,
//           intent_id: newIntent.id,
//         },
//         { merge: true }
//       );
//       return;
//     } catch (error) {
//       await snap.ref.collection('payment').doc('valid_check').set({ error: userFacingMessage(error) }, { merge: true });
//       await snap.ref.set({ error: userFacingMessage(error) }, { merge: true });
//     //  await reportError(error, { user: context.params.userId });
//     }
//   });

 


//   /**
//    * When a payment document is written on the client,
//    * this function is triggered to create the payment in Stripe.
//    *
//    * @see https://stripe.com/docs/payments/save-and-reuse#web-create-payment-intent-off-session
//    */
//   exports.createStripePayment = functions.firestore
//   .document('stripe_customers/{userId}/payments/{pushId}')
//   .onCreate(async (snap, context) => {
//     const amount = snap.data().amount;
//     const currency = snap.data().currency;
//     const payment_method = snap.data().payment_method;
//     const receipt_email = snap.data().receipt_email;
//     try {
//       // Look up the Stripe customer id.
//       const customer = (await snap.ref.parent.parent.get()).data().customer_id;
//       // Create a charge using the pushId as the idempotency key
//       // to protect against double charges.
//       const idempotencyKey = context.params.pushId;
//       const payment = await stripe.paymentIntents.create(
//         {
//           amount,
//           currency,
//           customer,
//           payment_method,
//           receipt_email: receipt_email,
//           confirm: true,
//           capture_method: 'manual',
//           confirmation_method: 'manual',
//         },
//         { idempotencyKey }
//       );
//       // If the result is successful, write it back to the database.
//       await snap.ref.collection('valid_check').doc('payment_intent').set(payment); //this is necessary to validate if paymnet method has been attached
//       await snap.ref.set(payment);
//       await snap.ref.set( {
//           ride_completed: false,
//           refund: false,
//         },
//         { merge:true}
//       );
//       return;
//     } catch (error) {
//       // We want to capture errors and render them in a user-friendly way, while
//       // still logging an exception with StackDriver
//       console.log(error);
//       await snap.ref.set({ error: userFacingMessage(error) }, { merge: true });
//     //  await reportError(error, { user: context.params.userId });
//     }
//   });

// //Once ride is completed, collect payment from card
// //This function will only be FULLY EXECUTED if the ride is completed.
//   exports.chargeStripePayment = functions.firestore
//   .document('stripe_customers/{userId}/payments/{pushId}')
//   .onUpdate(async (change, context) => {
//     try {
//       // Look up the Stripe customer id.
//       if (change.after.data().ride_completed === true) {
//         const paymentIntent = change.after.data().id;
//       //  const amount = change.data().amount;

//         const payment = await stripe.paymentIntents.capture(
//           paymentIntent
//         );
//         // If the result is successful, write it back to the database.
//         return change.after.ref.set(payment);
//       }
//     } catch (error) {
//       // We want to capture errors and render them in a user-friendly way, while
//       // still logging an exception with StackDriver
//       console.log(error);
//       return change.after.ref.set({ error: userFacingMessage(error) }, { merge: true });
//     //  await reportError(error, { user: context.params.userId });
//     }
//   });

// //CLOUD FUNCTION THAT WILL REFUND A payment
// //If firestore is updated and if only refund is changed to true, then this function will be called

// //ADD FUNCTIONALITY THAT ONLY ALLOWS ADMINS TO REFUND payments
// exports.refundStripePayment = functions.firestore
//   .document('stripe_customers/{userId}/payments/{pushId}/refund/refund_doc')
//   .onCreate(async (snap, context) => {
//     try {
//       //ONLU UNCOMMENT IF FIREBASE AUTHENTICATION and ADMIN TOKEN HAS BEEN ADDED\ AND ADMIN PORTAL HAS BEEN CREATED
//       /*
//         if (context.auth.token.admin !== true) {
//           await snap.ref.set({attemptedAt: Date.now(), response:"refund failed. Request is not from a admoin"), {merge:true}};
//         return Promis.resolve(null));
//       }
//       */
//       if (snap.data().refund === true) {
//         const paymentIntentID = (await snap.ref.parent.parent.get()).data().id;
//         const refund = await stripe.refunds.create({
//             payment_intent: paymentIntentID,
//         });
//         await snap.ref.set(refund);
//       /*  await snap.ref.parent.parent.set(
//           {
//             refund: true,
//           },
//           { merge: true }
//         );*/
//       }
//     } catch (error) {
//       // We want to capture errors and render them in a user-friendly way, while
//       // still logging an exception with StackDriver
//       console.log(error);
//       await snap.ref.set({ error: userFacingMessage(error) }, { merge: true });
//     }
//   });

//   /**
//   *NOT FULLY IMPLEMENTED I BELIEVE
//  * When 3D Secure is performed, we need to reconfirm the payment
//  * after authentication has been performed.
//  *
//  * @see https://stripe.com/docs/payments/accept-a-payment-synchronously
//  */
// exports.confirmStripePayment = functions.firestore
//   .document('stripe_customers/{userId}/payments/{pushId}')
//   .onUpdate(async (change, context) => {
//     if (change.after.data().status === 'requires_confirmation') {
//       const payment = await stripe.paymentIntents.confirm(
//         change.after.data().id
//       );
//       change.after.ref.set(payment);
//     }
//   })



exports.applyPromoCode = functions.https.onCall(async (data, context) => {
  try {
    const uid = data.uid;
    const promo_code = data.promo_code;
    // Get promo's data from firebase
    var promoRef = await admin
      .firestore().collection("promos").doc(promo_code).get();
    if (promoRef.exists) {
      // Check if reference exists in firebase
      var promo = promoRef.data(); // Get the Object
      // Get user's data and update credits with
      var userRef = await admin.firestore().collection("users").doc(uid).get();
      var user = userRef.data();
      if (promo.expiration.toDate() > new Date()) {
        // Compare expiration date
        if (!promo.redeemed_users.includes(uid)) {
          admin
            .firestore().collection("users").doc(uid)
            .update({
              credits: user.credits + promo.credits
            });
          // Update Promo's object with the user's id
          await admin
            .firestore().collection("promos").doc(promo_code)
            .update({
              redeemed_users: admin.firestore.FieldValue.arrayUnion(uid)
            });
          return {
            result: true,
            message: promo.message
          };
        } else {
          return {
            result: false,
            message: "You have already redeemed this code"
          };
        }
      } else {
        return {
          result: false,
          message: "Promo Code has expired"
        };
      }
    } else {
      return {
        result: false,
        message: "Invalid Promo Code"
      };
    }
  } catch (error) {
    console.log(error);
    return {
      result: false,
      message: "Server Error: Please try again later."
    };
  }
});






exports.driverClockIn = functions.https.onCall(async (data, context) => {
  //params
  var daysOfWeek = data.daysOfWeek;
  var isWorking = data.isWorking;
  var driveruid = data.driveruid;
  var shiftuid = data.shiftuid;
  
  //returns
  var result = false;
  var override = false;
  var message = " ";


  var currentTime = new Date(Date.now());

  if(isWorking == true) {
    result = false;
    message = "Driver is already clocked in";
  }

  //check days of week
  //not working to -> return  false 
  //allow client to override -> overrideClockIn()
  else if (!daysOfWeek.includes(currentTime.getDay())) {
    result = false;
    override = true;
    message = "Driver not scheduled for the day";
    console.log(message);

  }

  //get shift doc from firestore
  var shiftRef = await admin.firestore().collection("drivers").doc(driveruid)
    .collection("shifts").doc(shiftuid).get();
  if (shiftRef.exists)  {
    //shift holds the doc data
    var shift = shiftRef.data();

    //check startTime - if more than 10 min before scheduled time -> return false
    //allow override -> overrideClockIn
    if (currentTime.getTime() < shift.startTime.toDate() - 600000)  {
      result = false;
      override = true;
      message = "Driver not scheduled for time";
      console.log(message);
    }

    //driver scheduled to work
    else {
      //update firestore shift doc
      await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).update({
          'totalBreakTime': 0,
          'totalShiftTime': 0,
          shiftStart: currentTime,
          'overrideNeeded': false
        });

      //update isWorking in driverDoc
      await admin.firestore().collection("drivers").doc(driveruid).update({
        isWorking: true,
        'isAvailable': true
      });
      result = true;
      message = "Clock in successful"
      isWorking = true;
    }

  }else{
    //creates a new shift doc with shiftuid but requires override
    //requires override
    var newShift = new Date(currentTime);
    newShift.setMinutes(currentTime.getMinutes()-30);
    await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).set({
          shiftStart: newShift,
          'shiftEnd': newShift,
          'startTime': newShift,
          'endTime': newShift,
          'totalShiftTime': 0,
          'totalBreakTime': 0,
          'breakStart': newShift,
          'breakEnd': newShift,
          'overrideNeeded': true
        })
    result = false;
    override = true;
    message = "Driver not scheduled"
    console.log(message);
  }

  return{
    result: result,
    override: override,
    message: message,
    isWorking: isWorking
  }
})

exports.overrideClockIn = functions.https.onCall(async (data, context) => {
  var driveruid = data.driveruid;
  var shiftuid = data.shiftuid;

  var currentTime = new Date(Date.now());

  var result = false;
  var message = " ";

  //get shift doc from firestore
  var shiftRef = await admin.firestore().collection("drivers").doc(driveruid)
    .collection("shifts").doc(shiftuid).get();
  
  if (shiftRef.exists)  {
    //update firestore shift doc
    await admin.firestore().collection("drivers").doc(driveruid)
    .collection("shifts").doc(shiftuid).update({
      shiftStart: currentTime
    });
  }

  //cannot find shift doc
  else{
    await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).set({
          shiftStart: currentTime,
          'shiftEnd': currentTime,
          'startTime': currentTime,
          'endTime': currentTime,
          'totalShiftTime': 0,
          'totalBreakTime': 0,
          'breakStart': currentTime,
          'breakEnd': currentTime
        })
  }

  await admin.firestore().collection("drivers").doc(driveruid).update({
    isWorking: true,
    'isAvailable': true
  });

  result = true;
  message = "Clock in successful"
  console.log(message);
  return  {
    result: result,
    message: message
  }
  
})


exports.driverClockOut = functions.https.onCall(async (data, context) =>  {
  var driveruid = data.driveruid;
  var shiftuid = data.shiftuid;

  var currentTime = new Date(Date.now());
  var shiftTime;
  var message = " "
  var result = false;

  var driverRef = await admin.firestore().collection("drivers")
  .doc(driveruid).get();
  
  if (driverRef.exists) {

    var driverData = driverRef.data();

    //Driver is not currently clocked in
    if(!driverData.isWorking)  {
      message = "Driver is not clocked in";
    }

    //Driver is on break 
    else if(driverData.isOnBreak) {
      message = "Driver is on a break. You must end the break before clocking out.";
    }

    else  {

      //get shift doc from firestore
      var shiftRef = await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).get();
      
      if (shiftRef.exists)  {
        var shift = shiftRef.data();
        shiftTime = currentTime.getTime() - shift.shiftStart.toDate().getTime() - shift.totalBreakTime;

        var seconds = Math.floor((shiftTime / 1000) % 60);
        var minutes = Math.floor((shiftTime / (1000 * 60)) % 60);
        var hours = Math.floor((shiftTime / (1000 * 60 * 60)) % 24);
     
        var hours = (hours < 10) ? 0 + hours : hours;
        var minutes = (minutes < 10) ? 0 + minutes : minutes;
        var seconds = (seconds < 10) ? 0 + seconds : seconds;
        
        console.log("HOURS " + hours.toString());
        console.log("minutes " + minutes.toString());
        console.log("sec: " + seconds.toString());
        
        if (seconds > 30) {
          minutes = minutes+1;
        }
        var totalHoursSoFar = hours + (minutes/100);
        //update shiftEnd time
        await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).update({
          shiftEnd: currentTime,
          totalShiftTime: shiftTime,
          'totalBreakTime': 0,
          'shiftFinished': true
        });

        //update isWorking and isAvailable in driverDoc
        await admin.firestore().collection("drivers").doc(driveruid).update({
          'isWorking': false,
          'isAvailable': false,
          'totalHoursWorked': driverData.totalHoursWorked + totalHoursSoFar,
        });
        result = true;
        message = "Driver is successfully clocked out"
      }

      //Cannot find shift doc
      else{
        message = "No current shift"
      }
      
    }
  }

  //Driver doc not found
  else{
    message = "No Driver Found";
  }
  console.log(message);

  return{
    result: result,
    message: message,
  }
})



exports.driverStartBreak = functions.https.onCall(async (data, context) =>  {
  var driveruid = data.driveruid;
  var shiftuid = data.shiftuid;

  var currentTime = new Date(Date.now());

  var message = " "
  var result = false;

  //get driver doc from firestore
  var driverRef = await admin.firestore().collection("drivers")
  .doc(driveruid).get();
  
  //found driver doc
  if(driverRef.exists)  {

    var driverData = driverRef.data();

    //check if driver is currently on break
    if (driverData.isOnBreak)  {
      message = "Driver is already on break"
    }

    //check if driver is working
    else if (driverData.isWorking)  {
      
        //get shift doc from firestore
        var shiftRef = await admin.firestore().collection("drivers").doc(driveruid)
          .collection("shifts").doc(shiftuid).get();
        
        if (shiftRef.exists)  {

          //update breakstart
          await admin.firestore().collection("drivers").doc(driveruid)
            .collection("shifts").doc(shiftuid).update({
              'breakStart': currentTime
          });

          //update isOnBreak in  driverDoc
          await admin.firestore().collection("drivers").doc(driveruid).update({
            'isOnBreak': true,
            'isAvailable': false
          });
          result = true;
          message = "Break has started successfully";
        }

        //cannot find shift doc - ERROR
        else{
          message = "No current shift";
        }
    }

    //driver is not currently working
    else {
      message = "Driver not clocked in";
    }
  }

  //Cannot find driver doc
  else{
    message = "No Driver Found"
  }
  console.log(message);
  return  {
    result: result,
    message: message
  }
})



exports.driverEndBreak = functions.https.onCall(async (data, context) =>  {
  var driveruid = data.driveruid;
  var shiftuid = data.shiftuid;

  var currentTime = new Date(Date.now());
  var breakTime;
  var message = " "
  var result = false;

  //get driver doc from firestore
  var driverRef = await admin.firestore().collection("drivers")
  .doc(driveruid).get();
  
  if (driverRef.exists) {

    var driverData = driverRef.data();

    //Driver is not currently clocked in
    if(!driverData.isWorking)  {
      message = "Driver is not clocked in";
    }

    //Driver hasn't started a break
    else if(!driverData.isOnBreak) {
      message = "Driver hasn't started a break";
    }

    //Driver can end break
    else  {
      //get shift doc from firestore
      var shiftRef = await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).get();
      
      if (shiftRef.exists)  {
        var shift = shiftRef.data();
        breakTime = currentTime.getTime() - shift.breakStart.toDate().getTime();
        //update break end time
        await admin.firestore().collection("drivers").doc(driveruid)
        .collection("shifts").doc(shiftuid).update({
          breakEnd: currentTime,
          totalBreakTime: shift.totalBreakTime + breakTime
        });

        //update isOnBreak and isAvailable in driverDoc
        await admin.firestore().collection("drivers").doc(driveruid).update({
          'isOnBreak': false,
          'isAvailable': true
        });
        result = true;
        message = "Break has ended successfully"
      }

      //Cannot find shift doc
      else{
        message = "No current shift"
      }
      
    }
  }

  //Driver doc not found
  else{
    message = "No Driver Found";
  }

  console.log(message);
  return{
    result: result,
    message: message,
  }
})

exports.calculateCost = functions.https.onCall(async (data, context) => {
  var miles = data.miles; 
  var zipXL = data.zipXL //true, false
  var customerRequests = data.customerRequests;
  // -----------------------------------------------------------------------------------
  // not sure which variable the admin setting "price multiplier" is supposed to replace
  // pull from database but not sure where to put it:
  var priceMultiplier = (await admin.firestore().collection("config_settings").doc("admin_settings").get()).get('PriceMultiplier');

  // ------------------------------------------------------------------------------------
  var xlMultiplier =2;
  var multiplier = 4;
  var milesMultiplier = miles*0.5;

  var surgeMultiplier;
  var cost;

  if(zipXL) {
    xlMultiplier =3;
    if (customerRequests <= 4)  {
      surgeMultiplier =2;
    }
    else if (customerRequests == 5 )  {
      surgeMultiplier =4;
    }
    else  {
      surgeMultiplier = 4 + (0.2 * (customerRequests-5))
    }
  }
  else{
    if (customerRequests <= 6)  {
      surgeMultiplier = 2;
    }
    else if (customerRequests == 7) {
      surgeMultiplier = 4;
    }
    else{
      surgeMultiplier = 4 + (0.2 * (customerRequests - 7));
    }
  }
  cost = milesMultiplier * multiplier * xlMultiplier * surgeMultiplier;

  return{
    cost: cost
  }
})

exports.calculatePay = functions.https.onCall(async (data, context) => {
  var driveruid = data.driveruid;

  var result = false;
  var hours = 0;
  var payRate = 8;
  var pay = 0;

  //get driver doc from firestore
  var driverRef = await admin.firestore().collection("drivers")
  .doc(driveruid).get();
  
  //found driver doc
  if(driverRef.exists)  {
    var driverData = driverRef.data();
    hours = driverData.totalHoursWorked;
    pay = payRate * pay;
    result = true;
  }

  return{
    result: result,
    hours: hours,
    payment: pay
  }

});

//1st 15th 00:00 -> 0 0 0 1,15 * ?
exports.resetHours = functions.pubsub.schedule('0 0 1,15 * *')
  .timeZone('America/Chicago')
  .onRun(async (context) => {
    await admin.firestore().collection("drivers").get().then(function(querySnapshot) {
    querySnapshot.forEach(function(doc) {
        doc.ref.update({
            totalHoursWorked: 0
          });
      });
  });
  return null;
});