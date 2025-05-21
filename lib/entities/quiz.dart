import 'dart:convert';

class Quiz {
  final int? id;
  final int? userId;
  final String? title;
  final String? createdAt;
  final String? content;
  final String? image;

  Quiz({
    this.id,
    this.userId,
    this.title,
    this.createdAt,
    this.content,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'status': createdAt,
      'content': content,
      'image': image,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      createdAt: map['createdAt'],
      content: map['content'],
      image: map['image'],
    );
  }

  @override
  String toString() {
    return 'Quiz{id: $id, userId: $userId, title: $title, createdAt: $createdAt, content: $content, image: $image}';
  }
}
