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

  Future<bool> deleteQuestion(int id) async {
    try {
      var response = await http.delete(
        Uri.parse("${BaseUrl.url}/question/deleteQuestion/$id"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['result'] == 'Câu hỏi đã được xóa thành công';
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  Future<bool> updateQuestion(Question question) async {
    try {
      Map<String, dynamic> questionDTO = question.toMap();

      var response = await http.put(
        Uri.parse("${BaseUrl.url}/question/updateQuestion"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(questionDTO),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['result'] == 'Câu hỏi đã được cập nhật thành công';
      } else {
        print("Lỗi server: ${response.statusCode}");
        print("Nội dung phản hồi: ${utf8.decode(response.bodyBytes)}");
        return false;
      }
    } catch (e) {
      print("Đã xảy ra lỗi khi cập nhật câu hỏi: $e");
      return false;
    }
  }


}