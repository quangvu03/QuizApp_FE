import 'dart:convert';

class Answer {
  final int? id;
  final int? quizId;
  final int? questionId;
  final bool? correct;
  final String? content;
  final String? createdAt;

  Answer(
      {this.id,
      this.quizId,
      this.questionId,
      this.correct,
      this.content,
      this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'questionId': questionId,
      'correct': correct,
      'content': content,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'quizId': quizId,
      'questionId': questionId,
      'correct': correct,
      'content': content,
    };
  }


  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      quizId: map['quizId'],
      questionId: map['questionId'],
      correct: map['correct'],
      content: map['content'],
      createdAt: map['createdAt'],
    );
  }

  @override
  String toString() {
    return 'Answer{id: $id, quizId: $quizId, questionId: $questionId, correct: $correct, content: $content, createdAt: $createdAt}';
  }
}
