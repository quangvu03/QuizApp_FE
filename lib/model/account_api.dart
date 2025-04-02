import 'dart:convert';

import 'package:quizapp_fe/entities/user.dart';
import 'package:http/http.dart' as http;

import '../helpers/Url.dart';


class AccountApi{


  Future<bool> create(User User) async{
    try{
      var response = await http.post(
        Uri.parse("${BaseUrl.url}/account/create"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(User.toMap()),
      );
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

}