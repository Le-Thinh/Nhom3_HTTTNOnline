import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizmaker/models/question_model.dart';
import 'package:quizmaker/services/database.dart';
import 'package:quizmaker/views/result.dart';
import 'package:quizmaker/widgets/quiz_play_widgets.dart';
import 'package:quizmaker/widgets/widgets.dart';

class PlayQuiz extends StatefulWidget {
  final String quizId;
  PlayQuiz(this.quizId);

  @override
  State<PlayQuiz> createState() => _PlayQuizState();
}

int total = 0;
int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;

class _PlayQuizState extends State<PlayQuiz> {
  DatabaseService databaseService = new DatabaseService();
  QuerySnapshot? questionsSnapshot;

  QuestionModel getQuestionModeFromDatasnapshot(
      DocumentSnapshot questionSnapshot) {
    QuestionModel questionModel = new QuestionModel();
    if (questionSnapshot.exists) {
      questionModel.question = (questionSnapshot.get("question") as String?)!;
    }

    List<String> options = [
      (questionSnapshot.data() as Map<String, dynamic>?)?["option1"]
              as String? ??
          "",
      (questionSnapshot.data() as Map<String, dynamic>?)?["option2"]
              as String? ??
          "",
      (questionSnapshot.data() as Map<String, dynamic>?)?["option3"]
              as String? ??
          "",
      (questionSnapshot.data() as Map<String, dynamic>?)?["option4"]
              as String? ??
          "",
    ];

    options.shuffle();

    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];
    questionModel.correctOption = (questionSnapshot.get("option1") as String?)!;
    questionModel.answered = false;

    return questionModel;
  }

  @override
  void initState() {
    print("${widget.quizId}");
    databaseService.getQuizQuestionData(widget.quizId).then((value) {
      questionsSnapshot = value;
      _notAttempted = 0;
      _correct = 0;
      _incorrect = 0;
      total = questionsSnapshot?.docs.length ?? 0;

      print("$total this is total");
      setState(() {});
    });
    super.initState();
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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              questionsSnapshot == null
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: questionsSnapshot!.docs.length,
                      itemBuilder: (context, index) {
                        return QuizPlayTile(
                          questionModel: getQuestionModeFromDatasnapshot(
                              questionsSnapshot!.docs[index]),
                          index: index,
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Results(
                        incorrect: _incorrect,
                        total: total,
                        correct: _correct,
                        notattempted: _notAttempted)));
          }),
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  QuizPlayTile({required this.questionModel, required this.index});

  @override
  State<QuizPlayTile> createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Q${widget.index + 1}: ${widget.questionModel.question}",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (!widget.questionModel.answered) {
                  //correct
                  if (widget.questionModel.option1 ==
                      widget.questionModel.correctOption) {
                    setState(() {
                      optionSelected = widget.questionModel.option1;
                      widget.questionModel.answered = true;
                      _correct = _correct + 1;
                      _notAttempted = _notAttempted + 1;
                      print("${widget.questionModel.correctOption}");
                    });
                  } else {
                    setState(() {
                      optionSelected = widget.questionModel.option1;
                      widget.questionModel.answered = true;
                      _incorrect = _incorrect + 1;
                      _notAttempted = _notAttempted - 1;
                    });
                  }
                }
              },
              child: OptionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option1,
                option: "A",
                optionSelected: optionSelected,
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                if (!widget.questionModel.answered) {
                  //correct
                  if (widget.questionModel.option2 ==
                      widget.questionModel.correctOption) {
                    setState(() {
                      optionSelected = widget.questionModel.option2;
                      widget.questionModel.answered = true;
                      _correct = _correct + 1;
                      _notAttempted = _notAttempted + 1;
                      print("${widget.questionModel.correctOption}");
                    });
                  } else {
                    setState(() {
                      optionSelected = widget.questionModel.option2;
                      widget.questionModel.answered = true;
                      _incorrect = _incorrect + 1;
                      _notAttempted = _notAttempted - 1;
                    });
                  }
                }
              },
              child: OptionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option2,
                option: "B",
                optionSelected: optionSelected,
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                if (!widget.questionModel.answered) {
                  //correct
                  if (widget.questionModel.option3 ==
                      widget.questionModel.correctOption) {
                    setState(() {
                      optionSelected = widget.questionModel.option3;
                      widget.questionModel.answered = true;
                      _correct = _correct + 1;
                      _notAttempted = _notAttempted + 1;
                      print("${widget.questionModel.correctOption}");
                    });
                  } else {
                    setState(() {
                      optionSelected = widget.questionModel.option3;
                      widget.questionModel.answered = true;
                      _incorrect = _incorrect + 1;
                      _notAttempted = _notAttempted - 1;
                    });
                  }
                }
              },
              child: OptionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option3,
                option: "C",
                optionSelected: optionSelected,
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                if (!widget.questionModel.answered) {
                  //correct
                  if (widget.questionModel.option4 ==
                      widget.questionModel.correctOption) {
                    setState(() {
                      optionSelected = widget.questionModel.option4;
                      widget.questionModel.answered = true;
                      _correct = _correct + 1;
                      _notAttempted = _notAttempted - 1;
                      print("${widget.questionModel.correctOption}");
                    });
                  } else {
                    setState(() {
                      optionSelected = widget.questionModel.option4;
                      widget.questionModel.answered = true;
                      _incorrect = _incorrect + 1;
                      _notAttempted = _notAttempted - 1;
                    });
                  }
                }
              },
              child: OptionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option4,
                option: "D",
                optionSelected: optionSelected,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
