import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quizapp_fe/Page/createExam/TextEditorPage.dart';
import 'package:quizapp_fe/entities/answer.dart';
import 'package:quizapp_fe/entities/question.dart';
import 'package:quizapp_fe/model/answer_api.dart';
import 'package:quizapp_fe/model/question_api.dart';

class QuestionUpdatePage extends StatefulWidget {
  final Map<String, dynamic>? dataQuiz;
  final String questionType;
  final Map<String, dynamic>? questionData;

  const QuestionUpdatePage({
    Key? key,
    required this.dataQuiz,
    required this.questionType,
    this.questionData,
  }) : super(key: key);

  @override
  State<QuestionUpdatePage> createState() => _QuestionUpdatePageState();
}

class _QuestionUpdatePageState extends State<QuestionUpdatePage> {
  List<String> options = [];
  List<QuillController> optionControllers = [];
  QuillController questionController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );
  QuillController explanationController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );
  int? selectedOption;
  List<int> selectedOptions = [];
  bool? selectedTrueFalse;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeQuestionData();
  }

  void _initializeQuestionData() {
    if (widget.questionData != null) {
      try {
        final deltaJson = jsonDecode(widget.questionData!['content'] as String);
        questionController = QuillController(
          document: Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        questionController = QuillController(
          document: Document()..insert(0, 'Lỗi khởi tạo nội dung: $e'),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }

      final answers = List<Map<String, dynamic>>.from(widget.questionData!['answers'] ?? []);
      options = answers.map((answer) => answer['content'] as String).toList();
      optionControllers = answers.map((answer) {
        try {
          final deltaJson = jsonDecode(answer['content'] as String);
          return QuillController(
            document: Document.fromJson(deltaJson),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } catch (e) {
          return QuillController(
            document: Document()..insert(0, 'Lỗi khởi tạo đáp án: $e'),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      }).toList();

      if (widget.questionType == '1 đáp án') {
        for (int i = 0; i < answers.length; i++) {
          if (answers[i]['correct'] as bool) {
            selectedOption = i;
            break;
          }
        }
      } else if (widget.questionType == 'Nhiều đáp án') {
        selectedOptions = [];
        for (int i = 0; i < answers.length; i++) {
          if (answers[i]['correct'] as bool) {
            selectedOptions.add(i);
          }
        }
      } else if (widget.questionType == 'True/False') {
        for (int i = 0; i < answers.length; i++) {
          if (answers[i]['correct'] as bool) {
            selectedTrueFalse = i == 0;
            break;
          }
        }
      }

      if (widget.questionData!['explanation'] != null) {
        try {
          final deltaJson = jsonDecode(widget.questionData!['explanation'] as String);
          explanationController = QuillController(
            document: Document.fromJson(deltaJson),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } catch (e) {
          explanationController = QuillController(
            document: Document()..insert(0, 'Lỗi khởi tạo giải thích: $e'),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      }
    } else {
      if (widget.questionType == 'True/False') {
        options = [
          jsonEncode(Document().toDelta().toJson()),
          jsonEncode(Document().toDelta().toJson()),
        ];
        optionControllers = [
          QuillController(
            document: Document(),
            selection: const TextSelection.collapsed(offset: 0),
          ),
          QuillController(
            document: Document(),
            selection: const TextSelection.collapsed(offset: 0),
          ),
        ];
      } else {
        options = [
          jsonEncode(Document().toDelta().toJson()),
        ];
        optionControllers = [
          QuillController(
            document: Document(),
            selection: const TextSelection.collapsed(offset: 0),
          ),
        ];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in optionControllers) {
      controller.dispose();
    }
    questionController.dispose();
    explanationController.dispose();
    super.dispose();
  }

  void _syncLists() {
    if (options.length != optionControllers.length) {
      while (optionControllers.length > options.length) {
        optionControllers.last.dispose();
        optionControllers.removeLast();
      }
      while (optionControllers.length < options.length) {
        try {
          final deltaJson = jsonDecode(options[optionControllers.length]);
          optionControllers.add(
            QuillController(
              document: Document.fromJson(deltaJson),
              selection: const TextSelection.collapsed(offset: 0),
            ),
          );
        } catch (e) {
          optionControllers.add(
            QuillController(
              document: Document(),
              selection: const TextSelection.collapsed(offset: 0),
            ),
          );
        }
      }
    }
  }

  String _mapQuestionType(String questionType) {
    switch (questionType) {
      case '1 đáp án':
        return 'tracnghiem';
      case 'Nhiều đáp án':
        return 'nhieudapan';
      case 'True/False':
        return 'dungsai';
      default:
        return 'tracnghiem';
    }
  }

  Future<void> _deleteQuestion() async {
    if (widget.questionData == null || widget.questionData!['id'] == null) {
      return;
    }

    try {
      final questionApi = QuestionApi();
      final success = await questionApi.deleteQuestion(widget.questionData!['id']);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xóa câu hỏi thành công")),
        );
        Navigator.pop(context, {'deleted': true});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xóa câu hỏi thất bại")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa câu hỏi: $e")),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa câu hỏi này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteQuestion();
              },
              child: const Text(
                "Xóa",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncLists();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFCFBEFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.questionData != null
                          ? "Chỉnh sửa câu hỏi - ${widget.questionType}"
                          : "Tạo câu hỏi - ${widget.questionType}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.questionData != null) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showDeleteConfirmationDialog,
                            child: const Text(
                              "Xóa câu hỏi",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Text(
                        "Loại câu hỏi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.list_alt, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              widget.questionType,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Nội dung câu hỏi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final initialContent = jsonEncode(questionController.document.toDelta().toJson());
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextEditorPage(
                                initialContent: initialContent,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              try {
                                final deltaJson = jsonDecode(result);
                                questionController = QuillController(
                                  document: Document.fromJson(deltaJson),
                                  selection: const TextSelection.collapsed(offset: 0),
                                );
                              } catch (e) {
                                questionController = QuillController(
                                  document: Document()..insert(0, result),
                                  selection: const TextSelection.collapsed(offset: 0),
                                );
                              }
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
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
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Đáp án",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          if (index >= optionControllers.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (widget.questionType == '1 đáp án')
                                      Radio<int>(
                                        value: index,
                                        groupValue: selectedOption,
                                        onChanged: (int? value) {
                                          setState(() {
                                            selectedOption = value;
                                          });
                                        },
                                      ),
                                    if (widget.questionType == 'Nhiều đáp án')
                                      Checkbox(
                                        value: selectedOptions.contains(index),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedOptions.add(index);
                                            } else {
                                              selectedOptions.remove(index);
                                            }
                                          });
                                        },
                                      ),
                                    if (widget.questionType == 'True/False')
                                      Radio<bool>(
                                        value: index == 0,
                                        groupValue: selectedTrueFalse,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectedTrueFalse = value;
                                          });
                                        },
                                      ),
                                    Text(
                                      'Đáp án ${index + 1}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    if (widget.questionType != 'True/False')
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: isProcessing || options.length <= 1
                                            ? null
                                            : () {
                                          setState(() {
                                            isProcessing = true;
                                            options.removeAt(index);
                                            optionControllers[index].dispose();
                                            optionControllers.removeAt(index);
                                            if (widget.questionType == '1 đáp án') {
                                              if (selectedOption == index) {
                                                selectedOption = null;
                                              } else if (selectedOption != null &&
                                                  selectedOption! > index) {
                                                selectedOption = selectedOption! - 1;
                                              }
                                            } else if (widget.questionType == 'Nhiều đáp án') {
                                              selectedOptions.remove(index);
                                              selectedOptions = selectedOptions
                                                  .map((i) => i > index ? i - 1 : i)
                                                  .toList();
                                            }
                                            isProcessing = false;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final initialContent = jsonEncode(
                                        optionControllers[index].document.toDelta().toJson());
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TextEditorPage(
                                          initialContent: initialContent,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        try {
                                          final deltaJson = jsonDecode(result);
                                          options[index] = result;
                                          optionControllers[index] = QuillController(
                                            document: Document.fromJson(deltaJson),
                                            selection: const TextSelection.collapsed(offset: 0),
                                          );
                                        } catch (e) {
                                          options[index] = jsonEncode(
                                            (Document()..insert(0, result)).toDelta().toJson(),
                                          );
                                          optionControllers[index] = QuillController(
                                            document: Document()..insert(0, result),
                                            selection: const TextSelection.collapsed(offset: 0),
                                          );
                                        }
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: QuillEditor.basic(
                                      configurations: QuillEditorConfigurations(
                                        controller: optionControllers[index],
                                        autoFocus: false,
                                        enableInteractiveSelection: false,
                                        scrollable: false,
                                        padding: EdgeInsets.zero,
                                        expands: false,
                                      ),
                                      scrollController: ScrollController(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (widget.questionType != 'True/False')
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, color: Colors.blue),
                            label: const Text(
                              "Thêm đáp án",
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: isProcessing
                                ? null
                                : () {
                              setState(() {
                                isProcessing = true;
                                options.add(
                                  jsonEncode(Document().toDelta().toJson()),
                                );
                                optionControllers.add(
                                  QuillController(
                                    document: Document(),
                                    selection: const TextSelection.collapsed(offset: 0),
                                  ),
                                );
                                isProcessing = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        "Giải thích",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final initialContent = jsonEncode(
                              explanationController.document.toDelta().toJson());
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextEditorPage(
                                initialContent: initialContent,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              try {
                                final deltaJson = jsonDecode(result);
                                explanationController = QuillController(
                                  document: Document.fromJson(deltaJson),
                                  selection: const TextSelection.collapsed(offset: 0),
                                );
                              } catch (e) {
                                explanationController = QuillController(
                                  document: Document()..insert(0, result),
                                  selection: const TextSelection.collapsed(offset: 0),
                                );
                              }
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: explanationController,
                              autoFocus: false,
                              scrollable: false,
                              enableInteractiveSelection: false,
                              padding: EdgeInsets.zero,
                              expands: false,
                            ),
                            scrollController: ScrollController(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  if (questionController.document.isEmpty()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập nội dung câu hỏi")),
                    );
                    return;
                  }
                  if (widget.questionType == '1 đáp án' && selectedOption == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn một đáp án đúng")),
                    );
                    return;
                  }
                  if (widget.questionType == 'Nhiều đáp án' && selectedOptions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn ít nhất một đáp án đúng")),
                    );
                    return;
                  }
                  if (widget.questionType == 'True/False' && selectedTrueFalse == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn đáp án Đúng hoặc Sai")),
                    );
                    return;
                  }

                  // Create list of updated answers
                  List<Answer> listAnswer = [];
                  for (int index = 0; index < options.length; index++) {
                    bool correct;
                    if (widget.questionType == '1 đáp án') {
                      correct = index == selectedOption;
                    } else if (widget.questionType == 'Nhiều đáp án') {
                      correct = selectedOptions.contains(index);
                    } else {
                      correct = (index == 0 && selectedTrueFalse == true) ||
                          (index == 1 && selectedTrueFalse == false);
                    }

                    listAnswer.add(
                      Answer(
                        id: widget.questionData != null &&
                            index < widget.questionData!['answers'].length
                            ? widget.questionData!['answers'][index]['id']
                            : null,
                        quizId: widget.dataQuiz?['id'],
                        questionId: null, // Will be set after question update
                        correct: correct,
                        content: options[index],
                        createdAt: DateTime.now().toIso8601String(),
                      ),
                    );
                  }

                  List<int> oldAnswerIds = [];
                  if (widget.questionData != null && widget.questionData!['answers'] != null) {
                    oldAnswerIds = List<Map<String, dynamic>>.from(widget.questionData!['answers'])
                        .map((answer) => answer['id'] as int)
                        .toList();
                  }

                  // Create Question object with explanation
                  Question question = Question(
                    id: widget.questionData?['id'],
                    quizId: widget.dataQuiz?['id'],
                    content: jsonEncode(questionController.document.toDelta().toJson()),
                    title: widget.questionData?['title'] ?? "Câu hỏi mới",
                    type: _mapQuestionType(widget.questionType),
                    explanation: explanationController.document.isEmpty()
                        ? null
                        : jsonEncode(explanationController.document.toDelta().toJson()),
                    createdAt: widget.questionData?['createdAt'] ?? DateTime.now().toIso8601String(),
                  );

                  try {
                    setState(() {
                      isProcessing = true;
                    });

                    // Save or update question
                    final questionApi = QuestionApi();
                    int? questionId;
                    if (widget.questionData != null && widget.questionData!['id'] != null) {
                      // Update existing question
                      final questionResult = await questionApi.updateQuestion(question);
                      if (!questionResult) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cập nhật câu hỏi thất bại")),
                        );
                        return;
                      }
                      questionId = widget.questionData!['id'] as int;
                    } else {
                      // Create new question
                      final questionResult = await questionApi.saveQuestion(question);
                      if (questionResult == null || questionResult['idQuestion'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Tạo câu hỏi thất bại")),
                        );
                        return;
                      }
                      questionId = questionResult['idQuestion'] as int;
                    }

                    // Update questionId for answers
                    final updatedAnswers = listAnswer
                        .map((answer) => Answer(
                      id: answer.id,
                      quizId: answer.quizId,
                      questionId: questionId,
                      correct: answer.correct,
                      content: answer.content,
                      createdAt: answer.createdAt,
                    ))
                        .toList();

                    // Update answers
                    final answerApi = AnswerApi();
                    final answerResult = await answerApi.updateAnswers(
                      oldAnswerIds: oldAnswerIds,
                      updatedAnswers: updatedAnswers,
                    );

                    if (answerResult != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cập nhật câu hỏi và đáp án thành công: ID $questionId")),
                      );
                      Navigator.pop(context, {
                        'question': {'idQuestion': questionId},
                        'answers': answerResult,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cập nhật đáp án thất bại")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi cập nhật: $e")),
                    );
                  } finally {
                    setState(() {
                      isProcessing = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Lưu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}