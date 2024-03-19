import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/auth.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/screens/account/privacy_policy_screen.dart';
import 'package:zipapp/ui/screens/account/safety_screen.dart';
import 'package:zipapp/ui/screens/account/terms_screen.dart';
import 'package:zipapp/ui/widgets/underline_textbox.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ZipColors.primaryBackground,
        appBar: AppBar(
          toolbarHeight: 32.0,
          backgroundColor: ZipColors.primaryBackground,
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
                          userService.user.firstName[0] +
                              userService.user.lastName[0],
                          style: ZipDesign.pageTitleText,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                    '${userService.user.firstName} ${userService.user.lastName}',
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
                          value: userService.user.phone,
                          disabled: true),
                      const SizedBox(height: 16),
                      UnderlineTextbox.build(
                          labelText: 'Email',
                          value: userService.user.email,
                          disabled: true),
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
                                  onPressed: () {},
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
                            onPressed: () => AuthService().signOut(),
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
}
