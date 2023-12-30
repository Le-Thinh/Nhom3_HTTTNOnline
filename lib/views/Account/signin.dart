import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizmaker/helper/functions.dart';
import 'package:quizmaker/services/auth.dart';
import 'package:quizmaker/views/Screen_main/QuanTri/quantri_screen.dart';
import 'package:quizmaker/views/Screen_main/sinhvien_screen.dart';
import 'package:quizmaker/views/home.dart';
import 'package:quizmaker/views/Account/signup.dart';
import 'package:quizmaker/widgets/widgets.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  late String email, password;
  AuthServices authServices = new AuthServices();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void SignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await authServices.signInEmailAndPassword(email, password).then(
          (value) {
            if (value != null) {
              setState(() {
                _isLoading = false;
              });
              if (email.contains("qt")) {
                HelperFunctions.saveUserLoggedInDetails(isLoggedin: true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuanTriScreen(),
                  ),
                );
              } else if (email.contains("gv")) {
                HelperFunctions.saveUserLoggedInDetails(isLoggedin: true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              } else {
                HelperFunctions.saveUserLoggedInDetails(isLoggedin: true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SinhVienScreen(),
                  ),
                );
              }
            }
          },
        );
      } catch (e) {
        print("Đã xảy ra lỗi khi đăng nhập: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: _isLoading
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    TextFormField(
                      validator: (val) {
                        return val!.isEmpty ? "Enter correct email" : null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Email",
                      ),
                      onChanged: (val) {
                        email = val;
                      },
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      obscureText: true,
                      validator: (val) {
                        return val!.isEmpty ? "Enter correct password" : null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Password",
                      ),
                      onChanged: (val) {
                        password = val;
                      },
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        SignIn();
                      },
                      child: blueButton(
                        context: context,
                        label: "SignIn",
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 15.5),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot passowrd?",
                            style: TextStyle(
                              fontSize: 15.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
