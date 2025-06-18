import 'dart:convert';

class Question {
  final int? id;
  final int? quizId;
  final String? title;
  final String? type;
  final String? content;
  final String? createdAt;
  final String? explanation; // Thêm cột explanation

  Question({
    this.id,
    this.quizId,
    this.title,
    this.type,
    this.content,
    this.createdAt,
    this.explanation, // Thêm vào constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'title': title,
      'type': type,
      'content': content,
      'createdAt': createdAt,
      'explanation': explanation, // Thêm vào map
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      quizId: map['quizId'],
      title: map['title'],
      type: map['type'],
      content: map['content'],
      createdAt: map['createdAt'],
      explanation: map['explanation'], // Thêm vào fromMap
    );
  }

  @override
  String toString() {
    return 'Question{id: $id, quizId: $quizId, title: $title, type: $type, content: $content, explanation: $explanation, createdAt: $createdAt}'; // Cập nhật toString
  }
}