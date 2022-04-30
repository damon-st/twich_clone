import 'package:flutter/material.dart';
import 'package:twich_clone/responsive/responsive.dart';
import 'package:twich_clone/routes/routes.dart';
import 'package:twich_clone/widgets/custom_botton.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome to \n Twitch",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: CustomButton(
                    text: "Log in",
                    ontTap: () async {
                      await Navigator.pushNamed(context, Routes.login);
                    }),
              ),
              CustomButton(
                text: "Sing up",
                ontTap: () async {
                  await Navigator.pushNamed(context, Routes.singup);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
