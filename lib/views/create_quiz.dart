import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizmaker/services/database.dart';
import 'package:quizmaker/views/Account/signin.dart';
import 'package:quizmaker/views/addquestion.dart';
import 'package:quizmaker/widgets/widgets.dart';
import 'package:random_string/random_string.dart';

class CreateQuiz extends StatefulWidget {
  const CreateQuiz({super.key});

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final _formKey = GlobalKey<FormState>();
  late String quizImageUrl,
      quizTitle,
      quizDescription,
      quizId,
      quizCodeController;
  DatabaseService databaseService = new DatabaseService();
  String? currentUserId;

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignIn(),
        ),
      );
      //chuyển hướng đến màn hình đăng nhập.
    }
    super.initState();
  }

  bool _isLoading = false;

  createQuizOnline() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      quizId = randomAlphaNumeric(16);

      Map<String, String> quizMap = {
        "quizId": quizId,
        "quizImgurl": quizImageUrl,
        "quizTitle": quizTitle,
        "quizDescription": quizDescription,
        "createdBy": currentUserId!,
        "quizCode": quizCodeController,
      };
      await databaseService
          .addQuizzData(quizMap, quizId, currentUserId!, quizCodeController)
          .then((value) {
        setState(() {
          _isLoading = false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddQuestion(
                quizId: this.quizId,
              ),
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: appBar(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // Thay đổi icon tại đây
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty ? "Enter Image Url" : null,
                      decoration: const InputDecoration(
                        hintText: "Image (Url)",
                      ),
                      onChanged: (val) {
                        quizImageUrl = val;
                      },
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty ? "Enter Quizz Title" : null,
                      decoration: const InputDecoration(
                        hintText: "Title",
                      ),
                      onChanged: (val) {
                        quizTitle = val;
                      },
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty ? "Enter Quizz Description" : null,
                      decoration: const InputDecoration(
                        hintText: "Description",
                      ),
                      onChanged: (val) {
                        quizDescription = val;
                      },
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Enter Code" : null,
                      decoration: const InputDecoration(
                        hintText: "Code Quizz",
                      ),
                      onChanged: (val) {
                        quizCodeController = val;
                      },
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        createQuizOnline();
                      },
                      child: blueButton(
                        context: context,
                        label: "Create Quizz",
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }
}
