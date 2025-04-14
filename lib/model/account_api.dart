import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:quizapp_fe/entities/user.dart';
import 'package:http/http.dart' as http;

import '../helpers/Url.dart';

class AccountApi {
  Future<bool> create(User user) async {
    try {
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/account/create"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(user.toMap()),
      );
      print("usssseer: " + user.toString());
      print(response.body);
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        return res["result"];
      } else {
        throw Exception("Bad request");
      }
    } catch (e) {
      print("Login - Exception: $e");
      rethrow;
    }
  }

  Future<User> checkUsername(String username) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/account/findByUsername?username=${username}"),
      );
      dynamic res = jsonDecode(response.body);
      if (!res.containsKey("result")) {
        throw Exception("Invalid response: 'result' key not found");
      }
      if (response.statusCode == 200) {
        if (res["result"] is! Map<String, dynamic>) {
          throw Exception(
              "Invalid response: 'result' is not a valid user object");
        }
        return User.fromMap(res["result"]);
      } else if (response.statusCode == 400 && res["result"] == "not found") {
        throw Exception("Username not found");
      } else {
        throw Exception("Bad request - Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("checkUsername - Exception: $e");
      rethrow;
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      var response = await http.get(
        Uri.parse(
            "${BaseUrl.url}/account/findByEmail?email=${Uri.encodeComponent(email)}"),
      );
      // print("checkEmail response: ${response.body}");
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        if (res["result"] == "not found") {
          return false;
        }
        return true;
      } else {
        throw Exception("Bad request - Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("checkEmail - Exception: $e");
      rethrow;
    }
  }

  Future<User> Login(String username, String password) async {
    try {
      var response = await http.post(
        Uri.parse(
            "${BaseUrl.url}/account/login?username=$username&password=$password"),
      );
      print(Uri.parse(
          "${BaseUrl.url}/account/login?username=$username&password=$password"));
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        // Nếu res chứa key "result" và giá trị là "not found", ném exception
        if (res.containsKey("result") && res["result"] == "not found") {
          throw Exception("Login failed: Invalid username or password");
        }
        // Nếu không, res là dữ liệu người dùng trực tiếp
        if (res is! Map<String, dynamic>) {
          throw Exception("Invalid response: Expected a user object");
        }
        return User.fromMap(res);
      } else {
        throw Exception("Bad request - Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Login - Exception: $e");
      rethrow;
    }
  }

  Future<String> ChangePassword(String email, String password) async {
    try {
      var response = await http.post(
        Uri.parse(
            "${BaseUrl.url}/account/changePassword?email=$email&Changepassword=$password"),
      );
      print(Uri.parse(
          "${BaseUrl.url}/account/changePassword?email=$email&Changepassword=$password"));
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        return res["result"];
      } else {
        throw Exception("Bad request - Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("checklogin - Exception: $e");
      rethrow;
    }
  }

  Future<User> updateUser(int? id, User user) async {
    try {
      var response = await http.put(
        Uri.parse("${BaseUrl.url}/account/updateAccount/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(user.toMap()),
      );
      print(Uri.parse("${BaseUrl.url}/account/updateAccount/$id"));
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        return User.fromMap(res["result"]);
      } else {
        final errorRes = jsonDecode(response.body);
        throw Exception(errorRes["result"] ??
            "Bad request - Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("checklogin - Exception: $e");
      rethrow;
    }
  }

  Future<String> newPassword(
      String email, String password, String newPassword) async {
    try {
      final body = jsonEncode({
        "password": BCrypt.hashpw(password, BCrypt.gensalt()),
        "newPassword": BCrypt.hashpw(newPassword, BCrypt.gensalt()),
      });
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/account/newPassword?email=$email"),
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );
      print("${BaseUrl.url}/account/newPassword?email=$email");
      print("Request Body: $body");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        return res["result"];
      } else {
        try {
          dynamic errorRes = jsonDecode(response.body);
          String errorMessage = errorRes["result"] ?? "Yêu cầu không hợp lệ";
          return errorMessage;
        } catch (e) {
          return "Yêu cầu không hợp lệ - Mã lỗi: ${response.statusCode}";
        }
      }
    } catch (e) {
      print("newPassword - Exception: $e");
      return "Đã xảy ra lỗi: $e";
    }
  }
}
