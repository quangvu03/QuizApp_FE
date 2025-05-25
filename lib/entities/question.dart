import 'dart:convert';

class Question {
  final int? id;
  final int? quizId;
  final String? title;
  final String? type;
  final String? content;
  final String? createdAt;

  Question(
      {this.id,
      this.quizId,
      this.title,
      this.type,
      this.content,
      this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'title': title,
      'type': type,
      'content': content,
      'createdAt': createdAt,
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
    );
  }

  @override
  String toString() {
    return 'Answer{id: $id, quizId: $quizId, questionId: $title, correct: $type, content: $content, createdAt: $createdAt}';
  }
}
