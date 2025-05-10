import 'dart:convert';
import 'package:quizapp_fe/entities/Takeanswer.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp_fe/helpers/Url.dart';

 class TakeAnswerApi {

   Future<List<TakeAnswer>> saveTakeAnswers(List<TakeAnswer> answers) async {
     final response = await http.post(
       Uri.parse("${BaseUrl.url}/takeAnswer/saveListTakeAnswer"),
       headers: {'Content-Type': 'application/json'},
       body: jsonEncode(answers.map((a) => a.toMap()).toList()),
     );

     if (response.statusCode == 200) {
       final json = jsonDecode(response.body);
       final resultList = json['result'] as List;

       return resultList.map((item) => TakeAnswer.fromMap(item)).toList();
     } else {
       print("Lỗi: ${response.body}");
       throw Exception("Lỗi khi gửi take answers");
     }
   }


   Future<List<TakeAnswer>> fetchTakeAnswersByTakeId(int takeId) async {
     final response = await http.get(Uri.parse("${BaseUrl.url}/takeAnswer/findAllByTakeId?idTake=$takeId'"));

     if (response.statusCode == 200) {
       final Map<String, dynamic> jsonData = jsonDecode(response.body);
       final List<dynamic> list = jsonData['result'];
       return list.map((e) => TakeAnswer.fromMap(e)).toList();
     } else {
       throw Exception("Lỗi khi lấy dữ liệu: ${response.body}");
     }
   }

 }