import 'dart:convert';

class Take {
  final int? id;
  final int? userId;
  final int? quizId;
  final int? status;
  final int? score;
  final String? time;
  final int? correct;
  final String? finishedAt;

  Take({
    this.id,
    this.userId,
    this.quizId,
    this.status,
    this.score,
    this.time,
    this.correct,
    this.finishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'status': status,
      'score': score,
      'time': time,
      'correct': correct,
      'finishedAt': finishedAt,
    };
  }

  factory Take.fromMap(Map<String, dynamic> map) {
    return Take(
      id: map['id'],
      userId: map['userId'],
      quizId: map['quizId'],
      status: map['status'],
      score: map['score'],
      time: map['time'],
      correct: map['correct'],
      finishedAt: map['finishedAt'],
    );
  }

  @override
  String toString() {
    return 'Take{id: $id, userId: $userId, quizId: $quizId, status: $status, score: $score, time: $time, correct: $correct, finishedAt: $finishedAt}';
  }

  String toJson() => json.encode(toMap());

  factory Take.fromJson(String source) => Take.fromMap(json.decode(source));
}
