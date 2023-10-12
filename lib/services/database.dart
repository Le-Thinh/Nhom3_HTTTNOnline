import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  Future<void> addQuizzData(Map<String, String> quizData, String quizId) async {
    try {
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
      print(e);
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
}
