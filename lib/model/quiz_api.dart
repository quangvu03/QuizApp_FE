import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizapp_fe/helpers/Url.dart';

class QuizApiService {
  Future<List<Map<String, dynamic>>> fetchAllQuizzesByUser() async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.url}/quiz/findAllbyUser"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
          // Yêu cầu backend trả về UTF-8
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is List) {
          return List<Map<String, dynamic>>.from(data['result']);
        }
        throw Exception('Invalid response format');
      }
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['result'] ?? 'Failed to load user quizzes');
    } catch (e) {
      throw Exception('Error fetching user quizzes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllQuizz() async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.url}/quiz/findAll"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
          // Yêu cầu backend trả về UTF-8
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is List) {
          return List<Map<String, dynamic>>.from(data['result']);
        }
        throw Exception('Invalid response format');
      }
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['result'] ?? 'Failed to load quizzes');
    } catch (e) {
      throw Exception('Error fetching quizzes: $e');
    }
  }

  Future<Map<String, dynamic>> fetchQuizDetailRaw(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.url}/quiz/getdetails/$id"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is Map<String, dynamic>) {
          return data['result'];
        } else {
          throw Exception('Dữ liệu không đúng định dạng');
        }
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['result'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      throw Exception('Lỗi gọi API: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizdemoQuiz(int idquiz) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.url}/question/getDeilQuiz/$idquiz'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> result = data['result'];
      return result.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quiz detail');
    }
  }

  Future<List<Map<String, dynamic>>> findQuizByname(String name) async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.url}/quiz/findByName?name=${name}"),
        headers: {
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));


        final result = data['result'];
        final message = data['message'];

        if (result is List) {
          return List<Map<String, dynamic>>.from(result);
        } else if (message != null && message.contains("Không có dữ liệu")) {
          return [];
        } else {
          throw Exception('Invalid response format: $result');
        }
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['result'] ?? 'Failed to load quizzes');
      }
    } catch (e) {
      throw Exception('Error fetching user quizzes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> findByUserName(String username) async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.url}/quiz/findByUserName?username=${username}"),
        headers: {
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        final result = data['result'];

        if (result is List) {
          return List<Map<String, dynamic>>.from(result);
        } else if (result is String && result == "Không có dữ liệu") {
          return [];
        } else {
          throw Exception('Invalid response format: $result');
        }
      }

      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['result'] ?? 'Failed to load quizzes');
    } catch (e) {
      throw Exception('Error fetching quizzes: $e');
    }
  }
}
