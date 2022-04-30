import 'package:flutter/material.dart';
import 'package:twich_clone/resources/auth_methods.dart';
import 'package:twich_clone/responsive/responsive.dart';
import 'package:twich_clone/routes/routes.dart';
import 'package:twich_clone/widgets/custom_botton.dart';
import 'package:twich_clone/widgets/custom_textfiled.dart';
import 'package:twich_clone/widgets/loading_indicator.dart';

class SingUpScrenn extends StatefulWidget {
  const SingUpScrenn({Key? key}) : super(key: key);

  @override
  State<SingUpScrenn> createState() => _SingUpScrennState();
}

class _SingUpScrennState extends State<SingUpScrenn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final authMethods = AuthMethods();

  bool _isLoading = false;

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    bool res = await authMethods.signUpUser(_emailController.text,
        _usernameController.text, _passwordController.text, context);
    print(res);
    setState(() {
      _isLoading = false;
    });
    if (res) {
      Navigator.pushNamed(context, Routes.home);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
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
                        "Username",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomTextField(
                          controller: _usernameController,
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
                      CustomButton(text: "Sin Up", ontTap: signUpUser)
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
