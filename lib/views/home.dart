import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizmaker/helper/functions.dart';
import 'package:quizmaker/services/auth.dart';
import 'package:quizmaker/services/database.dart';
import 'package:quizmaker/views/Account/ResetPass.dart';
import 'package:quizmaker/views/Account/signin.dart';
import 'package:quizmaker/views/Screen_main/GiaoVien/giaovien_class.dart';
import 'package:quizmaker/views/create_quiz.dart';
import 'package:quizmaker/views/create_test_title.dart';
import 'package:quizmaker/views/edit_quiz.dart';
import 'package:quizmaker/views/list_score.dart';
import 'package:quizmaker/views/profile/profile_main.dart';
import 'package:quizmaker/widgets/widgets.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? quizId;
  Stream? quizStream;
  DatabaseService databaseService = new DatabaseService();
  late String currentUserId;
  List<QuizTile> userQuizTiles = [];

  void updateQuizStream() {
    databaseService.getQuizData().then((val) {
      setState(() {
        quizStream = val;
      });
    });
  }

  void RemoveQuiz(String quizId) {
    setState(() {
      userQuizTiles.removeWhere((quizTile) => quizTile.quizId == quizId);
    });
    databaseService.deleteQuiz(quizId);
  }

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

  Future<String> getCurrentUserId() async {
    String userId = 'Guest';
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await AuthServices.firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          userId = userDoc['id'] ?? 'Guest';
        }
      }
    } catch (e) {
      print("Lỗi nè: $e");
    }
    return userId;
  }

  Widget quizList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: StreamBuilder(
        stream: quizStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          } else {
            var querySnapshot =
                snapshot.data as QuerySnapshot<Map<String, dynamic>>;
            var quizList = querySnapshot.docs;

            List<QuizTile> userQuizTiles = [];

            for (var quizDoc in quizList) {
              var quiz = quizDoc.data() as Map<String, dynamic>;
              if (quiz.containsKey("quizImgurl") &&
                  quiz.containsKey("quizDescription") &&
                  quiz.containsKey("quizTitle") &&
                  quiz.containsKey("createdBy")) {
                String createdBy = quiz["createdBy"];
                if (createdBy == currentUserId) {
                  userQuizTiles.add(QuizTile(
                    imgUrl: quiz["quizImgurl"] as String,
                    desc: quiz["quizDescription"] as String,
                    title: quiz["quizTitle"] as String,
                    quizId: quiz["quizId"] as String,
                    deleteCallback: RemoveQuiz,
                  ));
                }
              }
            }

            return ListView.builder(
              itemCount: userQuizTiles.length,
              itemBuilder: (context, index) {
                return userQuizTiles[index];
              },
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    databaseService.getQuizData().then((val) {
      setState(() {
        quizStream = val;
      });
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignIn(),
        ),
      );
    }

    super.initState();
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
            onSelected: (value) async {
              if (value == 'Account') {}
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(),
                  ),
                );
              }
              if (value == 'Classes') {
                String teacherId = await getCurrentUserId();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassGiaoVienScreen(
                      teacherId: teacherId,
                    ),
                  ),
                );
              } else if (value == 'ResetPassword') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPassword(),
                  ),
                );
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
                  value: 'Classes',
                  child: Text('Classes'),
                ),
                const PopupMenuItem<String>(
                  value: 'ResetPassword',
                  child: Text('ResetPassword'),
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
      body: quizList(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Select the type! ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                contentPadding: EdgeInsets.all(16.0),
                content: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateQuiz(),
                          ),
                        );
                      },
                      child: Text("Create Quiz"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Điều hướng đến trang tạo Test khi nhấn vào nút "Test"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TestScreen(),
                          ),
                        );
                      },
                      child: Text("Create Test"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  DatabaseService databaseService = new DatabaseService();

  void deleteQuiz(String quizId) {
    databaseService.deleteQuiz(quizId);
  }

  void removeQuizFromList(BuildContext context, String quizId) {
    try {
      _HomeState? homeState = context.findAncestorStateOfType<_HomeState>();
      if (homeState != null) {
        removeQuizFromList(context, quizId);
        homeState.updateQuizStream();
        databaseService.deleteQuiz(quizId);
      } else {
        print("Error: _HomeState is null");
      }
    } catch (e) {
      print("Lỗi $e");
    }
  }

  final String imgUrl;
  final String title;
  final String desc;
  final String quizId;
  final Function(String) deleteCallback;

  QuizTile({
    Key? key,
    required this.imgUrl,
    required this.title,
    required this.desc,
    required this.quizId,
    required this.deleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListScore(
              quizId: quizId,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        height: 150,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imgUrl,
                width: MediaQuery.of(context).size.width - 48,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black26,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // Xử lý khi người dùng chọn "Edit"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditQuiz(quizId: quizId),
                      ),
                    );
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure ?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                deleteCallback(quizId);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else if (value ==
                      'points') {} //Phải làm lưu khi người dùng playquiz trước
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(
                          Icons.edit,
                        ),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
