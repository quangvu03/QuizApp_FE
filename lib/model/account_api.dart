import 'dart:convert';

import 'package:quizapp_fe/entities/user.dart';
import 'package:http/http.dart' as http;

import '../helpers/Url.dart';


class AccountApi{


  Future<bool> create(User user) async{

    try{
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/account/create"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(user.toMap()),

      );
      print("usssseer: "+user.toString());
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

  Future<bool> checkUsername(String username) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/account/findByUsername?username=${username}"),
      );
      // print("checkName response: ${response.body}");
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
      print("checkUsername - Exception: $e");
      rethrow;
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      var response = await http.get(
        Uri.parse("${BaseUrl.url}/account/findByEmail?email=${Uri.encodeComponent(email)}"),
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

  Future<bool> Login(String username,String password) async {
    try {
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/account/login?username=$username&password=$password"),
      );
      print( Uri.parse("${BaseUrl.url}/login?username=$username&password=$password"));
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
      print("checklogin - Exception: $e");
      rethrow;
    }
  }

  Future<String> ChangePassword(String email,String password) async {
    try {
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/account/changePassword?email=$email&Changepassword=$password"),
      );
      print( Uri.parse("${BaseUrl.url}/account/changePassword?email=$email&Changepassword=$password"));
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
          return res["result"] ;
      } else {
        throw Exception("Bad request - Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("checklogin - Exception: $e");
      rethrow;
    }
  }

}