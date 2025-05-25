import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quizapp_fe/Page/createExam/QuestionTypeDialog.dart';
import 'package:quizapp_fe/main.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'dart:convert';

class QuestionScreen extends StatefulWidget {
  final Map<String, dynamic>? dataQuiz;

  const QuestionScreen({super.key, required this.dataQuiz});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with WidgetsBindingObserver, RouteAware {
  Map<String, dynamic>? _dataQuiz;
  Future<List<Map<String, dynamic>>>? _questionsFuture;
  int selectedPage = 1;

  @override
  void initState() {
    super.initState();
    _dataQuiz = widget.dataQuiz;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshQuestions();
    });
  }

  bool _isFirstBuild = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    if (_isFirstBuild) {
      _isFirstBuild = false;
      _refreshQuestions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshQuestions();
  }

  void _refreshQuestions() {
    final id = widget.dataQuiz?['id'];
    setState(() {
      _questionsFuture = id != null
          ? QuizApiService().getExam(id).then((data) {
        final list = List<Map<String, dynamic>>.from(data['examQuizDTO'] ?? []);
        print("DATA LOADED: $list");
        return list;
      }).catchError((e) {
        print('Error initializing questions: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải câu hỏi: $e')),
        );
        return <Map<String, dynamic>>[];
      })
          : Future.value([]);
      print("_questionsFuture:: ${_questionsFuture.toString()}");
    });
  }

  Future<void> _refreshQuestionsAsync() async {
    final id = widget.dataQuiz?['id'];
    setState(() {
      _questionsFuture = id != null
          ? QuizApiService().getExam(id).then((data) {
        final list = List<Map<String, dynamic>>.from(data['examQuizDTO'] ?? []);
        return list;
      }).catchError((e) {
        print('Error initializing questions: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải câu hỏi: $e')),
        );
        return <Map<String, dynamic>>[];
      })
          : Future.value([]);
      print("_questionsFuture:: ${_questionsFuture.toString()}");
    });
  }

  final String examName = "Phần 1";
  final String status = "Hoạt động";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshQuestionsAsync,
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFF6A1B9A),
              elevation: 0,
              expandedHeight: 50,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Soạn câu hỏi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Đề thi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tên phần thi:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          examName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<List<Map<String, dynamic>>>(
                          key: ValueKey(_questionsFuture),
                          future: _questionsFuture,
                          builder: (context, snapshot) {
                            String headerText = 'Danh mục câu hỏi';
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              headerText = 'Danh mục câu hỏi (Đang tải...)';
                            } else if (snapshot.hasError) {
                              headerText = 'Danh mục câu hỏi (Lỗi)';
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              headerText = 'Danh mục câu hỏi (0 câu)';
                            } else {
                              headerText = 'Danh mục câu hỏi (${snapshot.data!.length} câu)';
                            }

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.list_alt, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(
                                    headerText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return QuestionTypeDialog(dataQuiz: _dataQuiz);
                                  },
                                );
                                if (result == true) {
                                  _refreshQuestions();
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Thêm câu hỏi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _questionsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            } else if (snapshot.hasError) {
                              return Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: Text('Lỗi khi tải câu hỏi')),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton(
                                      onPressed: _refreshQuestions,
                                      child: const Text('Thử lại'),
                                    ),
                                  ),
                                ],
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: Text('Không có câu hỏi nào')),
                              );
                            }

                            final questions = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                alignment: WrapAlignment.center,
                                children: List.generate(questions.length, (index) {
                                  final questionNumber = index + 1;
                                  return _buildPageButton(questionNumber, questions[index]);
                                }),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton(int pageNumber, Map<String, dynamic> question) {
    final isSelected = selectedPage == pageNumber;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPage = pageNumber;
        });
        _showQuestionDetailDialog(context, question);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.6),
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuestionDetailDialog(BuildContext context, Map<String, dynamic> question) {
    final questionContent = question['content'] as String;
    final questionType = question['type'] as String;
    final questionTitle = question['title'] as String;
    final answers = List<Map<String, dynamic>>.from(question['answers'] ?? []);

    // Tạo QuillController cho nội dung câu hỏi
    QuillController questionController;
    try {
      final deltaJson = jsonDecode(questionContent);
      questionController = QuillController(
        document: Document.fromJson(deltaJson),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      questionController = QuillController(
        document: Document()..insert(0, 'Lỗi hiển thị nội dung: $e'),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Tạo danh sách QuillController cho các đáp án
    final answerControllers = answers.map((answer) {
      try {
        final deltaJson = jsonDecode(answer['content'] as String);
        return QuillController(
          document: Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        return QuillController(
          document: Document()..insert(0, 'Lỗi hiển thị đáp án: $e'),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                questionTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Giải phóng bộ nhớ
                                  questionController.dispose();
                                  for (var controller in answerControllers) {
                                    controller.dispose();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Loại: $questionType',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nội dung câu hỏi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: QuillEditor.basic(
                              configurations: QuillEditorConfigurations(
                                controller: questionController,
                                autoFocus: false,
                                enableInteractiveSelection: false,
                                scrollable: false,
                                padding: EdgeInsets.zero,
                                expands: false,
                              ),
                              scrollController: ScrollController(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Đáp án',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(answers.length, (index) {
                            final answer = answers[index];
                            final isCorrect = answer['correct'] as bool;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isCorrect ? Colors.green : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isCorrect ? Colors.green.withOpacity(0.1) : null,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Đáp án ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isCorrect ? '(Đúng)' : '(Sai)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isCorrect ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    QuillEditor.basic(
                                      configurations: QuillEditorConfigurations(
                                        controller: answerControllers[index],
                                        autoFocus: false,
                                        enableInteractiveSelection: false,
                                        scrollable: false,
                                        padding: EdgeInsets.zero,
                                        expands: false,
                                      ),
                                      scrollController: ScrollController(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B6EF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Giải phóng bộ nhớ
                        questionController.dispose();
                        for (var controller in answerControllers) {
                          controller.dispose();
                        }
                      },
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}