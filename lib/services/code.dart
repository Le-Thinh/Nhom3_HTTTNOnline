import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CodeClassServices {
  final CollectionReference classCollection =
      FirebaseFirestore.instance.collection('classes');

  Future<void> addCodeClass(String classCode, String userId, String userEmail,
      String userName) async {
    try {
      await classCollection.add({
        'classCode': classCode,
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
      });
    } catch (e) {
      print('Error adding class code: $e');
    }
  }
}
