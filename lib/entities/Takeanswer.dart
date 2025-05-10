import 'package:intl/intl.dart';


class TakeAnswer {
   int? id;
   int? takeId;
   int? questionId;
   int? answerId;


  TakeAnswer(this.id, this.takeId, this.questionId, this.answerId);


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'takeId': takeId,
      'questionId': questionId,
      'answerId': answerId,
    };
  }

  TakeAnswer.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    takeId = map["takeId"];
    questionId = map["questionId"];
    answerId = map["answerId"];
  }

}
