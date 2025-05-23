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

  Future<Map<String, dynamic>> getDetailstakeExam(int idTake) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/take/getDetailsTake?idTake=$idTake"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is Map<String, dynamic>) {
          return data["result"];
        } else {
          print("Invalid response format");
          return {}; // Trả về map rỗng hoặc throw
        }
      } else {
        print("Lỗi khi lấy take: ${response.body}");
        return {}; // Trả về map rỗng hoặc throw
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return {}; // Trả về map rỗng hoặc throw
    }
  }

  Future<Map<String, dynamic>?> getAchievement(int idUser) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/take/getAvgTake?idUser=$idUser"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is Map<String, dynamic>) {
          return data["result"];
        } else {
          print("Invalid response format");
          return {};
        }
      } else {
        print("Lỗi khi lấy take: ${response.body}");
        return {};
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return {};
    }
  }

  Future<int?> countTakesByQuizCreator(int idUser) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/take/countTakesByQuizCreator?idUser=$idUser"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is int?) {
          return data["result"];
        } else {
          print("Invalid response format");
          return 0;
        }
      } else {
        print("Lỗi khi lấy take: ${response.body}");
        return 0;
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return 0;
    }
  }

}


