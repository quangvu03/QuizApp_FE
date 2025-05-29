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
        }
      } else {
        return null;
      }
    } catch (e) {
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
        }
      } else {
        return null;
      }
    } catch (e) {
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
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      return {};
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
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
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
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>?> getTakesByUserName(String userName) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/take/getTakeByUserName?username=$userName"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is List<dynamic>) {
          return List<Map<String, dynamic>>.from(
              data['result'].map((item) => Map<String, dynamic>.from(item)));
        } else {
          print("Invalid response format: result is not a list");
          return [];
        }
      } else {
        print("Error retrieving takes for user $userName: ${response.body}");
        return [];
      }
    } catch (e) {
      print("System error: $e");
      return [];
    }
  }

}


