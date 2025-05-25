import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizapp_fe/entities/question.dart';
import 'package:quizapp_fe/helpers/Url.dart';

class QuestionApi {
  Future<Map<String, dynamic>?> saveQuestion(Question question) async {
    try {
      Map<String, dynamic> questionDTO = question.toMap();
      //print("Dữ liệu gửi đi: ${json.encode(questionDTO)}");
      //print("Gửi đến endpoint: ${BaseUrl.url}/question/saveQuestion");

      var response = await http.post(
        Uri.parse("${BaseUrl.url}/question/saveQuestion"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(questionDTO),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        //print("Phản hồi từ server: $data");
        if (data['idQuestion'] != null) {
          return Map<String, dynamic>.from(data);
        } else {
          //print("Lỗi: Định dạng phản hồi không hợp lệ - ${data['result']}");
          return null;
        }
      } else {
        //print("Lỗi từ server: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      //print("Lỗi hệ thống: $e");
      return null;
    }
  }
}