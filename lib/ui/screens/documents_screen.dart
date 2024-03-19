import "package:flutter/material.dart";
//import 'package:zip/ui/screens/driver_settings_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 23.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //TopRectangle(
                Container(
                  color: Colors.black,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color.fromRGBO(255, 242, 0, 1.0)),
                          onPressed: onBackPress,
                        ),
                      ),
                      const Text("           Terms",
                          style: TextStyle(
                              //backgroundColor: Colors.black,
                              color: Color.fromRGBO(255, 242, 0, 1.0),
                              fontSize: 36.0,
                              fontWeight: FontWeight.w300,
                              fontFamily: "Bebas"))
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
                  child: Text(
                      "These Terms of Use (“Terms”) describe the Zip service, how you will be using it as a Rider, and important legal rights and responsibilities that you have in connection with it. These Terms are effective as to the “Last Updated” date above. \n\nPLEASE READ THESE TERMS CAREFULLY BEFORE USING ZIP.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          fontSize: 28.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "Bebas")),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
                  child: Text(
                      "1. Your relationship with Zip\n\nBy using the Zip website (www.zipgameday.com) or the Zip mobile application (“App”), by telephoning Zip, or by entering a vehicle used by a Zip Driver, you agree to be bound by these Terms.\n\nThese Terms create a contractual relationship between you and Zip. These Terms do not create any commercial or legal relationship of any type between you and any Zip Driver, Rider, or Passenger.\n\nZip (“we,” “our,” “us”) may update these Terms from time to time. Any such amendments will take effect as soon as Zip posts them on its Website or App. By continuing to use Zip after an update, you agree to be bound by the updated Terms.\n\n2. How you use the Service\n\nZip is an app-based event transportation service. It allows people at events who want a short ride by golf cart or pedicab from one location to another (“Riders”) to find people who are interested in driving them (“Drivers”). As a Rider, you can contact Zip to request a ride, and Zip will try to match you with a Driver who can pick you up and take you where you need to go. Right now, you can contact Zip through the App. These Terms refer to this service as the “Service.”\n\nHere's how the Service works. You contact Zip and request to be picked up at the location that you provide, and to be dropped off at another location not far away. Zip is for short drives, not road trips, so make it a trip less than five miles. Zip will dispatch one of its on-call Drivers to pick you up and drop you off. Zip will choose a Driver for you based on availability, and there may not be a Driver available quickly (or at all). Zip and Zip Drivers have the right to refuse the Service to you or to any Passengers for any reason at any time. If you don’t want to enter the Driver’s vehicle for any reason, you don’t have to. If you do, then just hop in and enjoy the ride. When you reach your destination, it’s nice to tip the Driver, but you don’t have to tip, and there’s no minimum amount if you do tip.\n\nYou may bring one or more friends into the vehicle with you (“Passengers”), if your Driver agrees to take them. If you request to bring a Passenger and your Driver agrees, then you agree to be personally responsible and financially liable for the Passenger’s conduct and to make sure the Passenger complies with these Terms to the same extent that you agree to.\n\nIf a Driver or another Rider or Passenger ever does anything that you don’t like in connection with the Service, please tell Zip immediately. We want this to be a great Service that people enjoy using. If anybody sexually harasses you, tell us. If anybody’s a jerk, tell us. If a Driver pressures you for a tip, which they have agreed with us not to do, tell us.\n\nTo use the Service, you must satisfy any eligibility criteria that Zip may adopt at any time. Any other use of this Service is unauthorized. If you use the Service in any unauthorized manner, then you agree to compensate Zip for its attorneys’ fees and any legal costs that may result from Zip’s initiation of any related legal action against you.\n\n3. Your authorizations to Zip\n\nIn order to match Riders with Drivers, Zip may collect some information about you. This may include your name, your phone number, and other information that Zip may request through the website, by phone, or through the App. You agree that Zip may collect this information and share it with Drivers for the limited purpose of helping them identify you at pickup locations or communicate with you about your ride, and may share it with third-party services.\n\nZip values your privacy. Please review our Rider Privacy Policy to learn how we collect and use information about you via the Service. By using the Service, you consent to Zip’s collection and use of information about you as set forth in that policy, and as it may be updated from time to time.\n\n4. The Rider’s Pledge\n\nPlease be courteous to your Driver and act responsibly. Here’s what we mean. When you’re in a Driver’s vehicle, you agree:\n\nDon’t harass a Driver or another Rider or Passenger. Don’t harass them verbally, physically, sexually, or otherwise.\n\nAlways wear your seat belt. If your seat belt doesn’t work, tell your Driver before the vehicle begins moving. If there is not a working seat belt, don’t ride.\n\nIf you receive a Driver’s phone number or other contact information in the course of using the Service, don’t use it for any reason except in connection with the Service. In particular, don’t use it to call them and ask for a date or to hang out, and don’t give the contact information to anybody else.\n\nDon’t do anything illegal.\n\nDon’t bring any illegal drugs or other illegal substances into the vehicle. Don’t bring any alcohol into the vehicle, whether it is an open or closed container.\nDon’t do anything that might cause an accident. For example, don’t distract the Driver.\n\nIf you are in contact with law enforcement officials or emergency medical personnel, follow their directions.\n\nDon’t use any type of tobacco product in the vehicle, and don’t smoke within twenty feet of it.\n\nFeel free to suggest the quickest route from your pickup location to the dropoff location if you know it, but if your Driver has a preferred route, let the Driver choose the route.\n\nThe Driver is the boss of his or her vehicle. If they ask you to do something, you agree to do so, whether that is to keep the noise level down, not to smoke, or otherwise, so long as they’re not asking you to do anything illegal or that would conflict with these Terms. The Driver also has the right to ask you to leave the vehicle at any time and for any reason.If they ask you to leave the vehicle, you agree to do so.\n\nIf you cause any damage to your Driver’s vehicle or cause the vehicle to require professional cleaning or detailing, you’ll pay the Driver’s reasonable costs of repair or cleaning.\n\nDon’t ask anybody else to violate any of these rules. If you bring any Passengers on the ride with you, make sure they follow them too.\n\n5. Termination\n\nEither you or Zip may immediately terminate these Terms at any time and for any reason, ending your use of the Service.\n\n6. Disclaimers, waiver of liability, and indemnity DISCLAIMER\n\nZIP OFFERS THE SERVICE “AS IS.” ZIP DISCLAIMS ALL REPRESENTATIONS AND WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, EXCEPT THOSE EXPRESSLY CONTAINED IN THESE TERMS, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. ZIP MAKES NO REPRESENTATION, WARRANTY, OR GUARANTEE CONCERNING THE RELIABILITY, TIMELINESS, QUALITY, OR AVAILABILITY OF THE SERVICE.\n\nYOU AGREE THAT YOU ALONE BEAR THE ENTIRE RISK OF USING THE SERVICE, TO THE EXTENT PERMITTED UNDER THE LAW.\n\nWAIVER OF LIABILITY\n\nNEITHER COMPANY NOR ITS DIRECTORS, OFFICERS, SHAREHOLDERS, PARTNERS OR EMPLOYEES (COLLECTIVELY, “REPRESENTATIVES”) IS AN INSURER; THAT YOU CURRENTLY HAVE AND SHALL ALWAYS MAINTAIN INSURANCE COVERING YOU, AND OTHERS WHO MAY BE ON THE PREMISES OR CARTS FOR MEDICAL, DISABILITY, LIFE, AND PROPERTY; THAT RECOVERY FOR ALL SUCH LOSS, DAMAGE AND EXPENSE SHALL BE LIMITED TO ANY SUCH INSURANCE COVERAGE ONLY: AND THAT COMPANY AND REPRESENTATIVES ARE RELEASED FROM ALL LIABILITY DUE TO ACTIVE OR PASSIVE SOLE, JOINT OR SEVERE NEGLIGENCE OF ANY KIND OR DEGREE, THE IMPROPER OPERATION OR NON-OPERATION OF THE CARTS OR APPS, BREACH OF CONTRACT, EXPRESS OR IMPLIED, BREACH OF WARRANTY, EXPRESS OR IMPLIED, OR BY LOSS OR DAMAGE TO OR MALFUNCTION OF APP, CARTS, FACILITIES, OR OPERATORS.THAT SHOULD THERE ARISE ANY LIABILITY ON THE PART OF COMPANY OR REPRESENTATIVES FOR ANY LOSS, DAMAGE OR EXPENSE DUE TO ACTIVE OR PASSIVE SOLE, JOINT OR SEVERE NEGLIGENCE OF ANY KIND OR DEGREE WHICH OCCURS BEFORE OR AFTER THE SIGNING OF THIS AGREEMENT, PRODUCT OR STRICT LIABILITY, BREACH OF WARRANTY, EXPRESS OR IMPLIED, BREACH OF CONTRACT, EXPRESS OR IMPLIED, OR FOR SUBROGATION, CONTRIBUTION OR INDEMNIFICATION, SUCH LIABILITY SHALL BE LIMITED TO THE MAXIMUM SUM OF \$1,000.00 FOR COMPANY AND REPRESENTATIVES.  ANY ACTION AGAINST THE COMPANY MUST BE COMMENCED WITHIN ONE YEAR OF THE ACCRUAL OF THE CAUSE OF ACTION OR SHALL BE BARRED.THE COMPANY NOR ITS REPRESENTATIVES WILL BE LIABLE UNDER ANY CIRCUMSTANCES TO YOU OR TO ANY OTHER PERSON FOR DAMAGES OF ANY TYPE (INCLUDING DIRECT, INDIRECT, LOST PROFIT, ECONOMIC, CONSEQUENTIAL, INCIDENTAL, SPECIAL, EXEMPLARY, OR PUNITIVE DAMAGES), PERSONAL INJURY, PROPERTY DAMAGE, OR FOR ANY CLAIM OR DEMAND AGAINST THE COMPANY BY ANY OTHER PERSON RELATED TO ANY USE OF THE SERVICE.\n\nIndemnification & Exculpatory Clause\n\nYou will indemnify and hold Zip and its officers, directors, employees, independent contractors (including Zip Drivers) and agents, and other Zip Riders and/or Passengers, harmless from any claims or expenses (including attorneys’ fees) arising in connection with the Service.  Customer agrees that Company is not an insurer and no insurance coverage is oﬀered herein.  Company is not assuming liability, and, therefore, shall not be liable to Customer for any loss or inability to retrieve data, personal injury or property damage sustained as a result of cart failure, equipment failure, theft, wreck, or any other cause, regardless of whether or not such loss or damage was caused by or contributed to by Company’s negligent performance to any degree in furtherance of this Agreement, any extra contractual or legal duty, strict products liability, or negligent failure to perform any obligation pursuant to this Agreement.  Customer agrees to indemnify the Company and to hold the Company harmless from and against any claims or demands which may be asserted against the Company.\n\n7. Miscellaneous\n\nNo transfer or assignment\n\nThe Service is for you alone. You agree not to assign or transfer your rights under these Terms to any other person, for financial gain or otherwise.\n\nEntire Agreement\n\nThese Terms are the final, complete, and exclusive understanding between the parties. They replace and supersede all previous oral or written communications or agreements between the parties with respect to the subject matter of these Terms. These Terms may not be modified or amended except in writing signed by an authorized representative of Zip or by an updated Terms of Service posted on the Zip website or App.\n\nGoverning Law and Jurisdiction\n\nThese terms will be governed by and construed in accordance with the laws of the state of Alabama. The federal and state courts in Alabama will have jurisdiction over any claim brought under these Terms or in connection with the Service, and the parties hereby consent to the personal jurisdiction of such courts.\n\nSeverability\n\nIf any provision of these Terms is held to be invalid, unenforceable, or illegal, that provision will be severed from the Terms, without effect to any other provisions of the Terms.\n\nResolving disputes\n\nIf you have any dispute with Zip, you agree to contact us in writing before filing a lawsuit and try in good faith to resolve the dispute. If you are not satisfied with that process, then the parties will arbitrate the dispute before an arbitrator that you and Zip agree to in writing in the State of Alabama. If the parties cannot agree on the choice of arbitrator, each party will appoint one individual representative and the two party representatives will, between themselves, choose an arbitrator.\n\nWaiver\n\nThe failure of either party to enforce any provisions of these Terms is not a waiver of the provisions or of the right of that party to subsequently enforce that, or any other, provision of these Terms.\n\n",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "Poppins")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;
  final posi;
  const TopRectangle(
      {super.key,
      this.posi,
      this.child,
      this.color,
      this.height = 100.0,
      this.width = 500.0});

  @override
  build(context) {
    return Container(
      width: width,
      height: height,
      color: const Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}
