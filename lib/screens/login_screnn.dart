import 'package:flutter/material.dart';
import 'package:twich_clone/resources/auth_methods.dart';
import 'package:twich_clone/responsive/responsive.dart';
import 'package:twich_clone/routes/routes.dart';
import 'package:twich_clone/widgets/custom_botton.dart';
import 'package:twich_clone/widgets/custom_textfiled.dart';
import 'package:twich_clone/widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final authMethods = AuthMethods();

  bool _isLoading = false;

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    bool r = await authMethods.loginUser(
        _emailController.text, _passwordController.text, context);

    setState(() {
      _isLoading = false;
    });
    if (r) {
      Navigator.of(context).pushNamed(Routes.home);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sing up",
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : Responsive(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.1,
                      ),
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomTextField(
                          controller: _emailController,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomTextField(
                          controller: _passwordController,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomButton(text: "Log In ", ontTap: loginUser)
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
