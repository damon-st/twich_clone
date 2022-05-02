import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twich_clone/providers/user_provider.dart';
import 'package:twich_clone/resources/auth_methods.dart';
import 'package:twich_clone/routes/routes.dart';
import 'package:twich_clone/screens/home_screnn.dart';
import 'package:twich_clone/screens/onboarding_screnn.dart';
import 'package:twich_clone/utils/colors.dart';
import 'package:twich_clone/models/user.dart' as model;
import 'package:twich_clone/widgets/loading_indicator.dart';
import 'package:wakelock/wakelock.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCUC7KVJc3QUE4_9TtVWdeQV0SiNVmxAGc",
          authDomain: "booksotore-3c766.firebaseapp.com",
          databaseURL: "https://booksotore-3c766.firebaseio.com",
          projectId: "booksotore-3c766",
          storageBucket: "booksotore-3c766.appspot.com",
          messagingSenderId: "310024197693",
          appId: "1:310024197693:web:a89dad22c0dc3c1ca2bc54",
          measurementId: "G-H6N025V2TY"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: backgroundColor,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: primaryColor,
          ),
        ),
      ),
      routes: Routes.routes,
      home: FutureBuilder(
        future: AuthMethods()
            .getCurrentUser(
          FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : null,
        )
            .then((value) {
          if (value != null) {
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).setUser(
              model.User.fromMap(value),
            );
          }
          return value;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const OnBoardingScreen();
          }
        },
      ),
    );
  }
}
