import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  Future<void> addQuizzData(Map<String, String> quizData, String quizId,
      String currentUserId, String quizCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      quizData["createdBy"] = user!.uid;
      quizData["quizCode"] = quizCode;

      await FirebaseFirestore.instance
          .collection("Quiz")
          .doc(quizId)
          .set(quizData)
          .catchError((e) {});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addQuestionData(
      Map<String, String> questionData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .add(questionData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getQuizData() async {
    try {
      return await FirebaseFirestore.instance.collection("Quiz").snapshots();
    } catch (e) {
      print("error $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuizzesByCode(String quizCode) async {
    QuerySnapshot quizSnapshot = await FirebaseFirestore.instance
        .collection("Quiz")
        .where("quizCode", isEqualTo: quizCode)
        .get();

    List<Map<String, dynamic>> quizzes = [];

    for (var doc in quizSnapshot.docs) {
      var quizData = doc.data() as Map<String, dynamic>;
      quizzes.add(quizData);
    }

    return quizzes;
  }

  getQuizQuestionData(String quizId) async {
    try {
      return await FirebaseFirestore.instance
          .collection("Quiz")
          .doc(quizId)
          .collection("QNA")
          .get();
    } catch (e) {
      print("error $e");
      return null;
    }
  }

  Future<bool> checkQuizCode(String quizCode) async {
    QuerySnapshot quiz = await FirebaseFirestore.instance
        .collection("Quiz")
        .where("quizCode", isEqualTo: quizCode)
        .get();

    return quiz.docs.isNotEmpty;
  }
}
