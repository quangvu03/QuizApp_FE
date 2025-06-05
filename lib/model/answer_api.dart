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

  Future<Map<String, dynamic>> updateAnswers({
    required List<int> oldAnswerIds,
    required List<Answer> updatedAnswers,
  }) async {
    try {
      List<Map<String, dynamic>> answerDTOs = updatedAnswers.map((answer) => answer.toMapWithoutId()).toList();
      print("Dữ liệu gửi đi: ${json.encode({
        "oldAnswerIds": oldAnswerIds,
        "newAnswers": answerDTOs,
      })}");

      var response = await http.put(
        Uri.parse("${BaseUrl.url}/answer/updateAnswers"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "oldAnswerIds": oldAnswerIds,
          "newAnswers": answerDTOs,
        }),
      );

      print("url: ${Uri.parse("${BaseUrl.url}/answer/updateAnswers")}");
      print("Mã trạng thái: ${response.statusCode}");
      print("Phản hồi: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print("Phản hồi từ server: $data");
        if (data['result'] is List) {
          return {"result": List<Map<String, dynamic>>.from(data['result'])};
        } else {
          print("Lỗi: Định dạng phản hồi không hợp lệ - ${data['result']}");
          return {"error": "Định dạng phản hồi không hợp lệ: ${data['result']}"};
        }
      } else {
        print("Lỗi từ server: ${response.statusCode} - ${response.body}");
        return {"error": "Lỗi server: ${response.statusCode} - ${response.body}"};
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return {"error": "Lỗi hệ thống: $e"};
    }
  }
}

