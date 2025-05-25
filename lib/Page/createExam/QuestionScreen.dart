import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/createExam/QuestionTypeDialog.dart';
import 'package:quizapp_fe/model/quiz_api.dart';

class QuestionScreen extends StatefulWidget {
  final Map<String, dynamic>? dataQuiz;

  const QuestionScreen({super.key, required this.dataQuiz});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? _dataQuiz;
  Future<List<Map<String, dynamic>>>? _questionsFuture;
  int selectedPage = 1;
  final int questionsPerPage = 10;
  bool _needsRefresh = false; // Cờ để kiểm soát làm mới

  @override
  void initState() {
    super.initState();
    _dataQuiz = widget.dataQuiz;
    WidgetsBinding.instance.addObserver(this);
    _refreshQuestions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _needsRefresh) {
      _refreshQuestions();
      _needsRefresh = false; // Reset cờ sau khi làm mới
    }
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

  final String examName = "Phần 1";
  final String status = "Hoạt động";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                        key: ValueKey(_questionsFuture), // Ép buộc rebuild
                        future: _questionsFuture,
                        builder: (context, snapshot) {
                          String headerText = 'Danh mục câu hỏi';
                          List<Widget> questionWidgets = [];

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            headerText = 'Danh mục câu hỏi (Đang tải...)';
                            questionWidgets = [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            ];
                          } else if (snapshot.hasError) {
                            print('Error loading questions: ${snapshot.error}');
                            headerText = 'Danh mục câu hỏi (Lỗi)';
                            questionWidgets = [
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
                            ];
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            headerText = 'Danh mục câu hỏi (0 câu)';
                            questionWidgets = [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: Text('Không có câu hỏi')),
                              ),
                            ];
                          } else {
                            final questions = snapshot.data!;
                            final startIndex = (selectedPage - 1) * questionsPerPage;
                            final endIndex =
                            (startIndex + questionsPerPage).clamp(0, questions.length);
                            final paginatedQuestions = questions.sublist(startIndex, endIndex);
                            headerText = 'Danh mục câu hỏi (${questions.length} câu)';
                            questionWidgets = paginatedQuestions.asMap().entries.map((entry) {
                              final index = startIndex + entry.key + 1;
                              final question = entry.value;
                              final answers =
                              List<Map<String, dynamic>>.from(question['answers'] ?? []);
                              return _buildQuestionItem(
                                index,
                                question['content'] ?? 'Không có nội dung',
                                answers
                                    .map((answer) => answer['content']?.toString() ?? '')
                                    .toList(),
                              );
                            }).toList();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
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
                              ),
                              ...questionWidgets,
                            ],
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
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return QuestionTypeDialog(dataQuiz: _dataQuiz);
                                },
                              );
                              _needsRefresh = true; // Đánh dấu cần làm mới khi quay lại
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
                          if (snapshot.connectionState == ConnectionState.waiting ||
                              snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final questions = snapshot.data!;
                          final totalPages = (questions.length / questionsPerPage).ceil();

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(totalPages, (index) {
                                final pageNumber = index + 1;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: _buildPageButton(pageNumber),
                                );
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
    );
  }

  Widget _buildQuestionItem(int number, String question, List<String> options) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu $number. $question',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            options.length,
                (index) => _buildOptionItem(
              String.fromCharCode(65 + index),
              options[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String prefix, String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $prefix. ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(option),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int pageNumber) {
    final isSelected = selectedPage == pageNumber;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPage = pageNumber;
        });
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
}