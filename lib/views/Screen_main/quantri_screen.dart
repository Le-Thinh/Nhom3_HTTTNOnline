import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizmaker/helper/functions.dart';
import 'package:quizmaker/models/user.dart';
import 'package:quizmaker/services/auth.dart';
import 'package:quizmaker/services/code.dart';
import 'package:quizmaker/views/Account/signin.dart';
import 'package:quizmaker/widgets/widgets.dart';

class QuanTriScreen extends StatefulWidget {
  const QuanTriScreen({Key? key}) : super(key: key);

  @override
  State<QuanTriScreen> createState() => _QuanTriScreenState();
}

class _QuanTriScreenState extends State<QuanTriScreen> {
  final _formKey = GlobalKey<FormState>();
  final CodeClassServices _codeClassServices = CodeClassServices();

  void _saveClassCode(
      String classCode, String userId, String userEmail, String userName) {
    _codeClassServices.addCodeClass(classCode, userId, userEmail, userName);
  }

  List<Users> userList = [];

  void _showUser(String role) async {
    String targetRole = (role == "student") ? "1" : "2";
    List<Users> users = await AuthServices().getUsersByRoleAndEmail(targetRole);
    print("Number of users: ${users.length}");
    setState(() {
      userList = users;
    });
  }

  void _onUserSelected(Users user) {
    // Hiển thị dialog và truyền thông tin người dùng vào hàm _saveClassCode
    _showClassCodeDialog(context, user);
  }

//Dialog

  void _showClassCodeDialog(BuildContext context, Users user) {
    TextEditingController classCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Class Code'),
          content: TextField(
            controller: classCodeController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Class Code',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                String classCode = classCodeController.text;
                String userId = user.uid;
                String userEmail = user.email;
                String userName = user.name;
                _saveClassCode(classCode, userId, userEmail, userName);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
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
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showUser("student");
                    },
                    child: blueButton(
                      context: context,
                      label: "Student",
                      buttonWidth: MediaQuery.of(context).size.width / 2 - 36,
                    ),
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showUser("teacher");
                    },
                    child: blueButton(
                      context: context,
                      label: "Teacher",
                      buttonWidth: MediaQuery.of(context).size.width / 2 - 36,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(userList[index].name),
                      subtitle: Text(userList[index].email),
                      trailing: GestureDetector(
                        onTap: () {
                          _showClassCodeDialog(context, userList[index]);
                        },
                        child: Icon(Icons.edit),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
