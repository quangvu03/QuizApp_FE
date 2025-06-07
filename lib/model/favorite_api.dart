import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizapp_fe/helpers/Url.dart';

class FavoriteApi {
  // Lấy danh sách yêu thích của người dùng theo userId
  Future<List<Map<String, dynamic>>?> getFavoritesByUserId(int userId) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/favorite/user/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is List<dynamic>) {
          return List<Map<String, dynamic>>.from(
              data['result'].map((item) => Map<String, dynamic>.from(item)));
        } else {
          print("Invalid response format: result is not a list");
          return [];
        }
      } else {
        print("Error retrieving favorites for user $userId: ${response.body}");
        return [];
      }
    } catch (e) {
      print("System error: $e");
      return [];
    }
  }

  // Thêm yêu thích
  Future<Map<String, dynamic>?> addFavorite(int quizId, int userId) async {
    try {
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/favorite/add?quizId=$quizId&userId=$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data['result']);
        } else {
          print("Invalid response format: result is not a map");
          return null;
        }
      } else {
        print("Error adding favorite: ${response.body}");
        return null;
      }
    } catch (e) {
      print("System error: $e");
      return null;
    }
  }

  // Xóa yêu thích
  Future<bool> deleteFavorite(int userId, int quizId) async {
    try {
      var response = await http.delete(
        Uri.parse("${BaseUrl.url}/favorite/delete?userId=$userId&quizId=$quizId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] == "Favorite deleted successfully") {
          return true;
        } else {
          print("Favorite not found: ${response.body}");
          return false;
        }
      } else {
        print("Error deleting favorite: ${response.body}");
        return false;
      }
    } catch (e) {
      print("System error: $e");
      return false;
    }
  }

  // Kiểm tra xem quiz có trong danh sách yêu thích của người dùng không
  Future<bool?> isQuizInUserFavorites(int quizId, int userId) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/favorite/check?quizId=$quizId&userId=$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['result'] is bool) {
          return data['result'] as bool;
        } else {
          print("Invalid response format: result is not a boolean");
          return null;
        }
      } else {
        print("Error checking favorite for quiz $quizId and user $userId: ${response.body}");
        return null;
      }
    } catch (e) {
      print("System error: $e");
      return null;
    }
  }
}