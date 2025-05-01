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
          'Accept': 'application/json; charset=UTF-8', // Yêu cầu backend trả về UTF-8
        },
      );

      // Kiểm tra header của response để debug
      print('Response headers (fetchAllQuizzesByUser): ${response.headers}');

      if (response.statusCode == 200) {
        // Giải mã dữ liệu từ response.bodyBytes theo UTF-8
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
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
          'Accept': 'application/json; charset=UTF-8', // Yêu cầu backend trả về UTF-8
        },
      );

      // Kiểm tra header của response để debug
      print('Response headers (fetchAllQuizz): ${response.headers}');

      if (response.statusCode == 200) {
        // Giải mã dữ liệu từ response.bodyBytes theo UTF-8
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
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
}