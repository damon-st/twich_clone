import 'package:flutter/cupertino.dart';
import 'package:twich_clone/screens/home_screnn.dart';
import 'package:twich_clone/screens/login_screnn.dart';
import 'package:twich_clone/screens/onboarding_screnn.dart';
import 'package:twich_clone/screens/singup_screnn.dart';

abstract class Routes {
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const singup = "/singup";
  static const home = "/homescrenn";

  static Map<String, Widget Function(BuildContext)> routes = {
    onboarding: (context) => const OnBoardingScreen(),
    login: (context) => const LoginScreen(),
    singup: (context) => const SingUpScrenn(),
    home: (context) => const HomeScreen(),
  };
}
