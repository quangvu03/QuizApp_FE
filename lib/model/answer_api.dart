import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizapp_fe/entities/answer.dart'; // Sử dụng Answer thay vì Take
import 'package:quizapp_fe/helpers/Url.dart';

class AnswerApi {
  Future<Map<String, dynamic>?> saveAnswers(List<Answer> answers) async {
    try {
      List<Map<String, dynamic>> answerDTOs = answers.map((answer) => answer.toMap()).toList();
      if (answerDTOs.isEmpty) {
        print("Lỗi: Danh sách đáp án rỗng");
        return null;
      }
      print("Dữ liệu gửi đi: ${json.encode(answerDTOs)}");

      var response = await http.post(
        Uri.parse("${BaseUrl.url}/answer/saveAnswer"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(answerDTOs),
      );

      print("url: ${Uri.parse("${BaseUrl.url}/api/answer/saveAnswer")}" );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print("Phản hồi từ server: $data");
        if (data['result'] is List) {
          return Map<String, dynamic>.from(data);
        } else {
          print("Lỗi: Định dạng phản hồi không hợp lệ - ${data['result']}");
          return null;
        }
      } else {
        print("Lỗi từ server: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return null;
    }
  }
}

