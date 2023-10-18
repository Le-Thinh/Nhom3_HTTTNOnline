import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizmaker/helper/functions.dart';
import 'package:quizmaker/services/auth.dart';
import 'package:quizmaker/services/database.dart';
import 'package:quizmaker/views/Account/signin.dart';
import 'package:quizmaker/views/play_quiz.dart';
import 'package:quizmaker/widgets/widgets.dart';

class SinhVienScreen extends StatefulWidget {
  const SinhVienScreen({super.key});

  @override
  State<SinhVienScreen> createState() => _SinhVienScreenState();
}

class _SinhVienScreenState extends State<SinhVienScreen> {
  String quizId = "";
  TextEditingController _quizCodeController = TextEditingController();
  List<Map<String, dynamic>> quizData = [];

  Future<String> getCurrentUserName() async {
    String userName = 'Guest';
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await AuthServices.firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          userName = userDoc['name'] ?? 'Guest';
        }
      }
    } catch (e) {
      print("Lỗi nè: $e");
    }
    return userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'Account') {}
              if (value == 'Settings') {
              } else if (value == 'Logout') {
                HelperFunctions.saveUserLoggedInDetails(isLoggedin: false);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const SignIn(),
                  ),
                  (Route<dynamic> route) =>
                      false, // Loại bỏ mọi màn hình khác khỏi ngăn xếp
                );
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Bo tròn góc của PopupMenuButton
            ),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Account',
                  child: ListTile(
                    leading: Icon(Icons.account_circle),
                    title: FutureBuilder<String>(
                      future: getCurrentUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(snapshot.data ?? 'Guest');
                      },
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: Text('Settings'),
                ),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Widget khác của bạn
            TextFormField(
              controller: _quizCodeController,
              decoration: InputDecoration(
                labelText: 'Enter Quiz Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) async {
                List<Map<String, dynamic>> fetchedQuizzes =
                    await DatabaseService().getQuizzesByCode(value);
                setState(() {
                  quizData = fetchedQuizzes;
                  if (quizData.isNotEmpty) {
                    quizId = quizData[0]['quizId'];
                  }
                });

                if (quizData.isNotEmpty) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No quizzes found for the entered code'),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            if (quizData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: quizData.length,
                  itemBuilder: (context, index) {
                    var quiz = quizData[index];
                    return ListTile(
                      title: Text(quiz['quizTitle']),
                      subtitle: Text(quiz['quizDescription']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayQuiz(quizId),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
