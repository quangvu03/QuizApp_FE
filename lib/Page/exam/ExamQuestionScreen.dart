import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizapp_fe/Page/exam/QuestionSelectionDialog.dart';
import 'package:quizapp_fe/Page/exam/QuizResultDetails.dart';
import 'package:quizapp_fe/entities/Takeanswer.dart';
import 'package:quizapp_fe/entities/take.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/Takeanswer_api.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:quizapp_fe/model/take_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class ExamQuestionScreen extends StatefulWidget {
  final int idquizd;
  final String examMode;
  final bool noTimeLimit;
  final bool showAnswersImmediately;
  final bool shuffleQuestions;
  final bool shuffleAnswers;
  final String? timeLimit;

  const ExamQuestionScreen(
      this.idquizd, {
        required this.examMode,
        required this.noTimeLimit,
        required this.showAnswersImmediately,
        required this.shuffleQuestions,
        required this.shuffleAnswers,
        this.timeLimit,
        Key? key,
      }) : super(key: key);

  @override
  State<ExamQuestionScreen> createState() => _ExamQuestionScreenState();
}

class _ExamQuestionScreenState extends State<ExamQuestionScreen> {
  int? _countCorrect;
  int? _selectedAnswer;
  bool _hasAnswered = false;
  Map<String, dynamic>? examapi;
  int? _number;
  int? totalQuestion;
  int? idUser;
  int? idQuiz;
  late QuizApiService _quizApiService;
  late TakeApi _takeApi;
  late TakeAnswerApi _takeAnswerApi;

  String? question;
  String? type;
  List<Map<String, dynamic>>? examQuizList;
  List<Map<String, dynamic>>? _shuffledExamQuizList;
  List<Map<String, dynamic>>? answers;
  var accountApi = AccountApi();
  final List<Map<String, dynamic>> _answerHistory = [];
  bool _hasPrintedAnswers = false;

  final ValueNotifier<int> _seconds = ValueNotifier<int>(0);
  late Timer _timer;
  int? _timeLimitInSeconds;

  @override
  void initState() {
    super.initState();
    _number = 1;
    _countCorrect = 0;
    _quizApiService = QuizApiService();
    _takeApi = TakeApi();
    _takeAnswerApi = TakeAnswerApi();
    idQuiz = widget.idquizd;
    _loadUser();
    fetchAPIexam(widget.idquizd);

    if (widget.examMode == 'test' && widget.timeLimit != null) {
      _timeLimitInSeconds = _parseTimeLimit(widget.timeLimit!);
      _seconds.value = _timeLimitInSeconds!;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_seconds.value > 0) {
          _seconds.value--;
        } else {
          if (!_hasPrintedAnswers) {
            _hasPrintedAnswers = true;
            printAllAnswers();
          }
          timer.cancel();
        }
      });
    } else {
      _seconds.value = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds.value++;
      });
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _timer.cancel();
    _seconds.dispose();
    super.dispose();
  }

  int _parseTimeLimit(String timeLimit) {
    final minutes = int.parse(timeLimit.split(' ')[0]);
    return minutes * 60;
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      try {
        User user = await accountApi.checkUsername(username);
        setState(() {
          idUser = user.id;
        });
      } catch (e) {
        ToastHelper.showError("Không thể tải thông tin người dùng");
      }
    } else {
      ToastHelper.showError("Vui lòng đăng nhập lại");
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}';
  }

  Future<void> fetchAPIexam(int idquiz) async {
    try {
      examapi = await _quizApiService.getExam(idquiz);

      setState(() {
        totalQuestion = examapi?["numberexamQuizDTO"] ?? 0;
        examQuizList = List<Map<String, dynamic>>.from(examapi?["examQuizDTO"] ?? []);
        if (examQuizList == null || examQuizList!.isEmpty) {
          ToastHelper.showError("Không tìm thấy câu hỏi cho bài kiểm tra này");
          question = "[]";
          type = "";
          answers = [];
          return;
        }

        if (_shuffledExamQuizList == null) {
          if (widget.shuffleQuestions) {
            _shuffledExamQuizList = List.from(examQuizList!)..shuffle();
          } else {
            _shuffledExamQuizList = List.from(examQuizList!);
          }

          if (widget.shuffleAnswers) {
            for (var question in _shuffledExamQuizList!) {
              question['answers'] = List.from(question['answers'] ?? [])..shuffle();
            }
          }
        }

        if (_number! < 1 || _number! > _shuffledExamQuizList!.length) {
          _number = 1;
        }

        int questionIndex = _number! - 1;
        question = _shuffledExamQuizList![questionIndex]["content"] ?? "[]";
        type = _shuffledExamQuizList![questionIndex]["type"] ?? "";
        answers = List<Map<String, dynamic>>.from(_shuffledExamQuizList![questionIndex]["answers"] ?? []);

        int currentQuestionId = _shuffledExamQuizList![questionIndex]["id"];
        var historyEntry = _answerHistory.firstWhere(
              (entry) => entry['questionId'] == currentQuestionId,
          orElse: () => {},
        );

        if (historyEntry.isNotEmpty) {
          int? answerId = historyEntry['answerId'];
          _selectedAnswer = answers?.indexWhere((answer) => answer["id"] == answerId);
          _hasAnswered = _selectedAnswer != null && _selectedAnswer != -1;
        } else {
          _selectedAnswer = null;
          _hasAnswered = false;
        }
      });
    } catch (e) {
      setState(() {
        ToastHelper.showError("Lỗi khi tải bài kiểm tra: $e");
        question = "[]";
        type = "";
        answers = [];
      });
    }
  }

  void _saveAnswerToHistory(int questionNumber, int? selectedAnswer) {
    int questionId = _shuffledExamQuizList![questionNumber - 1]["id"];
    int? answerId = selectedAnswer != null ? answers![selectedAnswer]["id"] : null;
    int existingIndex = _answerHistory.indexWhere((entry) => entry['questionId'] == questionId);

    Map<String, dynamic> newEntry = {
      'questionId': questionId,
      'answerId': answerId,
    };

    if (existingIndex != -1) {
      _answerHistory[existingIndex] = newEntry;
    } else {
      _answerHistory.add(newEntry);
    }

    if (widget.examMode == 'practice' && !_hasPrintedAnswers && areAllQuestionsAnswered()) {
      _hasPrintedAnswers = true;
      printAllAnswers();
    }
  }

  bool areAllQuestionsAnswered() {
    if (_shuffledExamQuizList == null || _shuffledExamQuizList!.isEmpty) {
      return false;
    }

    for (var question in _shuffledExamQuizList!) {
      int questionId = question['id'];
      var historyEntry = _answerHistory.firstWhere(
            (entry) => entry['questionId'] == questionId,
        orElse: () => {},
      );

      if (historyEntry.isEmpty || historyEntry['answerId'] == null) {
        return false;
      }
    }

    return true;
  }

  Future<void> printAllAnswers() async {
    int correctCount = 0;
    for (var question in _shuffledExamQuizList!) {
      int questionId = question['id'];
      var historyEntry = _answerHistory.firstWhere(
            (entry) => entry['questionId'] == questionId,
        orElse: () => {},
      );

      if (historyEntry.isNotEmpty && historyEntry['answerId'] != null) {
        var answers = List<Map<String, dynamic>>.from(question['answers'] ?? []);
        var selectedAnswer = answers.firstWhere(
              (answer) => answer['id'] == historyEntry['answerId'],
          orElse: () => {'content': '[]', 'correct': false},
        );

        if (selectedAnswer['correct'] == true) {
          correctCount++;
        }
      }
    }

    setState(() {
      _countCorrect = correctCount;
    });

    String formattedTime;
    if (widget.examMode == 'test' && _timeLimitInSeconds != null) {
      int usedSeconds = _timeLimitInSeconds! - _seconds.value;
      formattedTime = _formatTime(usedSeconds);
    } else {
      formattedTime = _formatTime(_seconds.value);
    }

    _timer.cancel();
    double score = totalQuestion! > 0 ? (10 / totalQuestion!) * _countCorrect! : 0;
    final data = await _takeApi.saveTake(Take(
      score: score,
      correct: _countCorrect,
      time: formattedTime,
      quizId: idQuiz,
      userId: idUser,
    ));

    int idTake = data!["id"];

    List<TakeAnswer> takeAnswers = _answerHistory
        .map((item) => TakeAnswer.fromMap({
      ...item,
      'takeId': idTake,
    }))
        .toList();

    final dataAnswer = await _takeAnswerApi.saveTakeAnswers(takeAnswers);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          totalQuestion!,
          _countCorrect!,
          formattedTime,
          dataAnswer,
          _shuffledExamQuizList,
          idTake,
          idQuiz!,
        ),
      ),
    );
  }

  Future<void> _showSubmitConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận nộp bài'),
          content: const Text('Bạn có muốn hoàn thành bài thi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Có'),
              onPressed: () {
                if (!_hasPrintedAnswers) {
                  _hasPrintedAnswers = true;
                  printAllAnswers();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận thoát'),
          content: const Text('Bạn có muốn thoát khỏi bài thi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Thoát'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    late quill.Document questionDoc;
    try {
      final deltaJson = jsonDecode(question ?? "[]");
      questionDoc = quill.Document.fromJson(deltaJson);
    } catch (e) {
      questionDoc = quill.Document()..insert(0, 'Nội dung câu hỏi không hợp lệ');
    }
    final questionController = quill.QuillController(
      document: questionDoc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return WillPopScope(
      onWillPop: _showExitConfirmationDialog,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8BBD0),
                Color(0xFFFCE4EC),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black54,
                            size: 15,
                          ),
                          onPressed: () async {
                            bool shouldExit = await _showExitConfirmationDialog();
                            if (shouldExit) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
                            const SizedBox(width: 4),
                            ValueListenableBuilder<int>(
                              valueListenable: _seconds,
                              builder: (context, seconds, child) {
                                return Text(
                                  _formatTime(seconds),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      if (widget.examMode == 'test')
                        SizedBox(
                          width: 80,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              _showSubmitConfirmationDialog();
                            },
                            child: const Text(
                              "Nộp bài",
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, left: 16, bottom: 0, top: 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Câu $_number:',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                              Text(
                                '$type',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          quill.QuillEditor.basic(
                            configurations: quill.QuillEditorConfigurations(
                              controller: questionController,
                              autoFocus: false,
                              enableInteractiveSelection: false,
                              scrollable: false,
                              padding: EdgeInsets.zero,
                              expands: false,
                              customStyles: quill.DefaultStyles(
                                paragraph: quill.DefaultTextBlockStyle(
                                  const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  const quill.VerticalSpacing(2, 2),
                                  const quill.VerticalSpacing(0, 0),
                                  null,
                                ),
                              ),
                            ),
                            scrollController: ScrollController(),
                          ),
                          const SizedBox(height: 16),
                          answers == null || answers!.isEmpty
                              ? const Text(
                            'Không có đáp án nào để hiển thị',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: answers?.length ?? 0,
                            itemBuilder: (context, index) {
                              final answer = answers![index];
                              bool isCorrect = answer["correct"] == true;
                              bool isSelected = _selectedAnswer == index;
                              Color backgroundColor = Colors.white;

                              if (_hasAnswered && widget.showAnswersImmediately) {
                                if (isCorrect) {
                                  backgroundColor = Colors.green[100]!;
                                } else if (isSelected && !isCorrect) {
                                  backgroundColor = Colors.red[100]!;
                                }
                              }

                              late quill.Document answerDoc;
                              try {
                                final deltaJson = jsonDecode(answer["content"]?.toString() ?? "[]");
                                answerDoc = quill.Document.fromJson(deltaJson);
                              } catch (e) {
                                answerDoc = quill.Document()..insert(0, 'Đáp án không hợp lệ');
                              }
                              final answerController = quill.QuillController(
                                document: answerDoc,
                                selection: const TextSelection.collapsed(offset: 0),
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: RadioListTile<int>(
                                    title: quill.QuillEditor.basic(
                                      configurations: quill.QuillEditorConfigurations(
                                        controller: answerController,
                                        autoFocus: false,
                                        enableInteractiveSelection: false,
                                        scrollable: false,
                                        padding: EdgeInsets.zero,
                                        expands: false,
                                        customStyles: quill.DefaultStyles(
                                          paragraph: quill.DefaultTextBlockStyle(
                                            const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            const quill.VerticalSpacing(2, 2),
                                            const quill.VerticalSpacing(0, 0),
                                            null,
                                          ),
                                        ),
                                      ),
                                      scrollController: ScrollController(),
                                    ),
                                    value: index,
                                    groupValue: _selectedAnswer,
                                    onChanged: widget.examMode == 'test' || !_hasAnswered
                                        ? (int? value) {
                                      setState(() {
                                        _selectedAnswer = value;
                                        if (widget.examMode == 'practice') {
                                          _hasAnswered = true;
                                        }
                                        _saveAnswerToHistory(_number!, value);
                                      });
                                    }
                                        : null,
                                    activeColor: const Color(0xFF673AB7),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF06292),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            if (_number! > 1) {
                              setState(() {
                                _number = _number! - 1;
                                fetchAPIexam(widget.idquizd);
                              });
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_outlined, size: 18, color: Colors.white),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () async {
                                final selectedQuestion = await showQuestionSelectionDialog(
                                  context,
                                  totalQuestion,
                                  _number,
                                  _answerHistory,
                                  _shuffledExamQuizList,
                                );
                                if (selectedQuestion != null) {
                                  setState(() {
                                    _number = selectedQuestion;
                                    fetchAPIexam(widget.idquizd);
                                  });
                                }
                              },
                              child: Text(
                                '$_number/$totalQuestion câu',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF06292),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: () {
                            if (_number! < totalQuestion!) {
                              setState(() {
                                _number = _number! + 1;
                                fetchAPIexam(widget.idquizd);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int?> showQuestionSelectionDialog(
      BuildContext context,
      int? totalQuestion,
      int? number,
      List<Map<String, dynamic>> answerHistory,
      List<Map<String, dynamic>>? examQuizList) async {
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return QuestionSelectionDialog(
          number: totalQuestion,
          questionAt: number,
          answerHistory: answerHistory,
          examQuizList: examQuizList,
        );
      },
    );
  }
}