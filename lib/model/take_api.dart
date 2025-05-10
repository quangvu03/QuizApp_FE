import 'dart:convert';
import 'package:quizapp_fe/entities/take.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp_fe/helpers/Url.dart';

class TakeApi {
  Future<Map<String, dynamic>?> saveTake(Take take) async {
    try {
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/take/saveTake"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(take.toMap()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data['result']);
        } else {
          print("Invalid response format");
        }
      } else {
        print("Lỗi khi lưu take: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return null;
    }
  }
  Future<Take?> findById(int id) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/take/getTakeById/$id"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is Map<String, dynamic>) {
          return Take.fromMap(data["result"]);
        } else {
          print("Invalid response format");
        }
      } else {
        print("Lỗi khi lưu take: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return null;
    }
  }

}
