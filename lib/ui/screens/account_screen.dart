import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/auth.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/screens/driver_only/driver_portal_screen.dart';
import 'package:zipapp/ui/screens/driver_only/driver_verification_screen.dart';
import 'package:zipapp/ui/screens/edit_account_screen.dart';
import 'package:zipapp/ui/screens/privacy_policy_screen.dart';
import 'package:zipapp/ui/screens/rider_only/rider_main_screen.dart';
import 'package:zipapp/ui/screens/safety_screen.dart';
import 'package:zipapp/ui/screens/terms_screen.dart';
import 'package:zipapp/ui/widgets/underline_textbox.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  final bool driver;
  const AccountScreen({super.key, required this.driver});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

final Uri _url = Uri.parse('https://zipgameday.com');

class _AccountScreenState extends State<AccountScreen> {
  final UserService userService = UserService();

  late String firstName;
  late String lastName;
  late String email;
  late String phone;

  late bool verifiedDriver;

  @override
  void initState() {
    super.initState();
    firstName = userService.user.firstName;
    lastName = userService.user.lastName;
    email = userService.user.email;
    phone = userService.user.phone;
    verifiedDriver = userService.user.isDriver;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ZipColors.primaryBackground,
        appBar: AppBar(
          toolbarHeight: 32.0,
          backgroundColor: ZipColors.primaryBackground,
          scrolledUnderElevation: 0,
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(children: <Widget>[
              Center(
                child: userService.user.profilePictureURL != ""
                    ? CircleAvatar(
                        radius: 48,
                        backgroundImage:
                            NetworkImage(userService.user.profilePictureURL),
                      )
                    : CircleAvatar(
                        radius: 48,
                        backgroundColor: ZipColors.zipYellow,
                        foregroundColor: Colors.black,
                        child: Text(
                          firstName[0].toUpperCase() +
                              lastName[0].toUpperCase(),
                          style: ZipDesign.pageTitleText,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('$firstName $lastName',
                    style: ZipDesign.pageTitleText),
              ),
              const SizedBox(height: 24),

              /// Basic Info section, including phone number, email, and password
              Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Basic Info',
                            style: ZipDesign.sectionTitleText),
                      ),
                      const SizedBox(height: 16),
                      UnderlineTextbox.build(
                          labelText: 'Phone number',
                          value: phone,
                          disabled: true),
                      const SizedBox(height: 16),
                      UnderlineTextbox.build(
                          labelText: 'Email', value: email, disabled: true),
                      const SizedBox(height: 16),
                      UnderlineTextbox.build(
                          labelText: 'Password',
                          value: '••••••••',
                          disabled: true),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: TextButton.icon(
                                  onPressed: () => editAccount(),
                                  icon: const Icon(LucideIcons.pencil),
                                  label: const Text('Edit account details'),
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(0)),
                                    iconColor:
                                        MaterialStateProperty.all(Colors.black),
                                    iconSize: MaterialStateProperty.all(16),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    backgroundColor: MaterialStateProperty.all(
                                        ZipColors.zipYellow),
                                    textStyle: MaterialStateProperty.all(
                                        ZipDesign.labelText),
                                  )))
                        ],
                      )
                    ],
                  )),
              const SizedBox(height: 16),

              /// Important Links section, including links to the rules and safety, privacy policy, terms and conditions, and logout
              Align(
                  alignment: Alignment.centerLeft,
                  child: Column(children: <Widget>[
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Important Links',
                          style: ZipDesign.sectionTitleText),
                    ),
                    const SizedBox(height: 16),
                    Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SafetyScreen()),
                              );
                            },
                            icon: const Icon(LucideIcons.shield),
                            label: const Text('Rules and Safety'),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(0)),
                              iconColor:
                                  MaterialStateProperty.all(Colors.black),
                              iconSize: MaterialStateProperty.all(16),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              textStyle: MaterialStateProperty.all(
                                  ZipDesign.labelText),
                            ))),
                    const SizedBox(height: 16),
                    Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TermsScreen()),
                              );
                            },
                            icon: const Icon(LucideIcons.book),
                            label: const Text('Terms and Conditions'),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(0)),
                              iconColor:
                                  MaterialStateProperty.all(Colors.black),
                              iconSize: MaterialStateProperty.all(16),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              textStyle: MaterialStateProperty.all(
                                  ZipDesign.labelText),
                            ))),
                    const SizedBox(height: 16),
                    Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyScreen()),
                              );
                            },
                            icon: const Icon(LucideIcons.lock),
                            label: const Text('Privacy Policy'),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(0)),
                              iconColor:
                                  MaterialStateProperty.all(Colors.black),
                              iconSize: MaterialStateProperty.all(16),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              textStyle: MaterialStateProperty.all(
                                  ZipDesign.labelText),
                            ))),
                    const SizedBox(height: 16),
                    Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              _launchUrl();
                            },
                            icon: const Icon(LucideIcons.badgeHelp),
                            label: const Text('Help Center'),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(0)),
                              iconColor:
                                  MaterialStateProperty.all(Colors.black),
                              iconSize: MaterialStateProperty.all(16),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              textStyle: MaterialStateProperty.all(
                                  ZipDesign.labelText),
                            ))),
                    const SizedBox(height: 16),
                    swapRiderOrDriver(),
                    const SizedBox(height: 16),
                    Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () => _logOut(),
                            icon: const Icon(LucideIcons.logOut),
                            label: const Text('Logout'),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(0)),
                              iconColor:
                                  MaterialStateProperty.all(Colors.black),
                              iconSize: MaterialStateProperty.all(16),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              textStyle: MaterialStateProperty.all(
                                  ZipDesign.labelText),
                            ))),
                  ]))
            ])));
  }

  void editAccount() async {
    final List<String> list = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const EditAccountScreen()));
    setState(() {
      firstName = list[0];
      lastName = list[1];
      email = list[2];
      phone = list[3];
    });
  }

  Widget swapRiderOrDriver() {
    return Align(
      alignment: Alignment.topLeft,
      child: TextButton.icon(
        onPressed: () {
          if (widget.driver) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RiderMainScreen(),
              ),
            );
          } else {
            if (verifiedDriver) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverVerificationScreen(),
                ),
              );
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DriverPortal()));
            }
          }
        },
        icon:
            Icon(widget.driver ? LucideIcons.personStanding : LucideIcons.car),
        label: Text(widget.driver
            ? 'Use our Rider Program'
            : verifiedDriver
                ? 'Login as Driver'
                : 'Become a Driver'),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
          iconColor: MaterialStateProperty.all(Colors.black),
          iconSize: MaterialStateProperty.all(16),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          textStyle: MaterialStateProperty.all(ZipDesign.labelText),
        ),
      ),
    );
  }

  void _logOut() async {
    AuthService().signOut();
    Navigator.of(context).pushNamed("/root");
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
