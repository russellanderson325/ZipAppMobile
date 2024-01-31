import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zipapp/ui/screens/main_screen.dart';
import 'package:zipapp/ui/screens/profile_screen.dart';
import 'package:zipapp/ui/screens/root_screen.dart';
import 'package:zipapp/ui/screens/sign_in_screen.dart';
import 'package:zipapp/ui/screens/sign_up_screen.dart';
import 'package:firebase_core/firebase_core.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // runApp(const MainApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance().then((prefs) {
    runApp(MainApp(prefs: prefs));
  });
}

class MainApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MainApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zip Gameday',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: <String, WidgetBuilder>{
        '/root': (BuildContext context) => const RootScreen(),
        '/signin': (BuildContext context) => const SignInScreen(),
        '/signup': (BuildContext context) => const SignUpScreen(),
        '/main': (BuildContext context) => const MainScreen(),
        '/profile': (BuildContext context) => const ProfileScreen(),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.grey,
      ),
      home: _handleCurrentScreen(),
    );
  }

  Widget _handleCurrentScreen() {
    return const RootScreen();
  }
}
