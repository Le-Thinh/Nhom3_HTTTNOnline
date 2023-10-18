import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizmaker/models/user.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  Users? _userFromFirebaseUser(User user) {
    return user != null
        ? Users(
            uid: user.uid,
            name: user.displayName ?? "",
            role: "",
            email: user.email ?? "")
        : null;
    // Users(uid: user.uid);
  }

  Future signInEmailAndPassword(String email, String password) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = authResult.user;
      DocumentSnapshot userdoc =
          await firestore.collection('users').doc(firebaseUser?.uid).get();

      if (userdoc.exists) {
        String name = userdoc['name'];
        String role = userdoc['role'];
        if (name.isEmpty) {
          name = firebaseUser?.displayName ?? '';
          await firestore.collection('users').doc(firebaseUser?.uid).update({
            'name': name,
          });
        }
        return _userFromFirebaseUser(firebaseUser!);
      } else {
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      throw e;
    }
  }

  Future signUpWithEmailAndPassword(
      String email, String password, String name, String role) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = authResult.user;

      late String roleUser;
      if (email.contains("gv")) {
        roleUser = "2";
      } else if (email.contains("qt")) {
        roleUser = "0";
      } else {
        roleUser = "1";
      }

      await firestore.collection('users').doc(firebaseUser?.uid).set({
        'password': password,
        'name': name,
        'email': email,
        'role': roleUser,
      });
      return _userFromFirebaseUser(firebaseUser!);
    } catch (e) {
      print("Lỗi: $e");
      throw e;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Users>> getUsersByRoleAndEmail(String role) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();

    List<Users> users = [];
    querySnapshot.docs.forEach((doc) {
      users.add(Users.fromJson(doc.data() as Map<String, dynamic>));
    });
    return users;
  }

  Future<String> getUserRole(String userID) async {
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(userID).get();
    if (userDoc.exists) {
      return userDoc['role'] ?? '1';
    }
    return '1';
  }
}
