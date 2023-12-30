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

  Future<void> deleteQuiz(String quizId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Xóa câu hỏi từ collection "Quiz"
        await FirebaseFirestore.instance
            .collection('Quiz')
            .doc(quizId)
            .delete();

        // Xóa câu hỏi từ collection "QNA" trong quiz
        await FirebaseFirestore.instance
            .collection('Quiz')
            .doc(quizId)
            .collection('QNA')
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      } else {
        print("User is not logged in.");
      }
    } catch (e) {
      print("Lỗi: $e");
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
      print("lỗi ở đây nè: $e");
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
      print("lỗi ở đây nè: $e");
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

// Hàm lấy thông tin Quiz từ Firestore dựa trên quizId
  Future<void> getQuizDetails(String quizId) async {
    DocumentSnapshot<Map<String, dynamic>> quizDoc = await FirebaseFirestore
        .instance
        .collection('quizzes')
        .doc(quizId)
        .get();
    // TODO: Xử lý dữ liệu lấy được và cập nhật các giá trị trong màn hình chỉnh sửa câu hỏi
    // ...
  }

  // Hàm lấy thông tin câu hỏi từ Firestore dựa trên questionId
  Future<void> getQuestionDetails(String questionId) async {
    DocumentSnapshot<Map<String, dynamic>> questionDoc = await FirebaseFirestore
        .instance
        .collection('questions')
        .doc(questionId)
        .get();

    // TODO: Xử lý dữ liệu lấy được và cập nhật các giá trị trong màn hình chỉnh sửa câu hỏi
    // ...
  }

  // Hàm lưu các thay đổi của Quiz vào Firestore
  Future<void> saveQuizChanges(
      Map<String, dynamic> quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(quizId)
        .update(quizData);

    // TODO: Xử lý các thao tác sau khi lưu thành công (nếu cần)
    // ...
  }

  // Hàm lưu các thay đổi của câu hỏi vào Firestore
  Future<void> saveQuestionChanges(
      Map<String, dynamic> questionData, String questionId) async {
    await FirebaseFirestore.instance
        .collection('questions')
        .doc(questionId)
        .update(questionData);

    // TODO: Xử lý các thao tác sau khi lưu thành công (nếu cần)
    // ...
  }
}
