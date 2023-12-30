import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizmaker/helper/functions.dart';
import 'package:quizmaker/services/auth.dart';
import 'package:quizmaker/views/Account/signin.dart';
import 'package:quizmaker/views/Screen_main/sinhvien_screen.dart';
import 'package:quizmaker/views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isUserLoggedIn = false;
  String? userRole;

  getLoggedInState() async {
    bool? loggedIn = await HelperFunctions.getUserLoggedInDetails();
    if (loggedIn != null) {
      setState(() {
        isUserLoggedIn = loggedIn;
      });
    } else {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  Future<void> checkUserLoginStatus() async {
    bool? loggedIn = await HelperFunctions.getUserLoggedInDetails();
    if (loggedIn != null && loggedIn) {
      // Nếu người dùng đã đăng nhập, lấy vai trò người dùng
      String role = await getUserRole();
      setState(() {
        isUserLoggedIn = true;
        userRole = role;
      });
    } else {
      // Nếu người dùng chưa đăng nhập
      setState(() {
        isUserLoggedIn = false;
        userRole = null;
      });
    }
  }

  Future<String> getUserRole() async {
    String _role = "0";
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot roleDoc = await AuthServices.firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (roleDoc.exists) {
          _role = roleDoc['role'] ?? "0";
        }
      }
    } catch (e) {
      print("Lỗi: $e");
    }
    return _role;
  }

  @override
  void initState() {
    // getLoggedInState().then((loggedIn) {
    //   if (loggedIn != null) {
    //     getUserRole().then((role) {
    //       setState(() {
    //         userRole = role;
    //       });
    //     });
    //   }
    // });
    checkUserLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isUserLoggedIn) {
      if (userRole == "2") {
        return Home();
      } else if (userRole == "1") {
        return SinhVienScreen();
      } else {
        return SignIn();
      }
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SignIn(),
      );
    }
  }
}
