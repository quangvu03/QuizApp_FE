import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:quizapp_fe/entities/quiz.dart';
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

  Future<Map<String, dynamic>> getExam(int idQuiz) async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.url}/question/getExam/${idQuiz}"),
        headers: {
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      }
    } catch (e) {
      throw Exception('Error fetching quizzes: $e');

    }
  }

  Future<List<Map<String, dynamic>>> findAllbyUserId(int UserId) async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.url}/quiz/findByUserId?userId=$UserId"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
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

  Future<Map<String, dynamic>> createQuiz(Quiz quiz, File? avatar) async {
    try {
      // Tạo multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${BaseUrl.url}/quiz/createQuiz"),
      );
      request.headers['Accept'] = 'application/json; charset=UTF-8';
      request.fields['title'] = quiz.title!;
      request.fields['content'] = quiz.content!;
      request.fields['userId'] = quiz.userId.toString();

      // Chỉ thêm avatar nếu không null
      if (avatar != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
          contentType: MediaType('image', avatar.path.split('.').last.toLowerCase()),
        );
        request.files.add(multipartFile);
      }else{
        request.fields['image'] = quiz.image.toString();
      }

      var response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return decodedResponse['result'] as Map<String, dynamic>;
      } else {
        throw Exception(decodedResponse['result'] ?? 'Failed to create quiz');
      }
    } catch (e) {
      throw Exception('Error creating quiz: $e');
    }
  }

}

void main() async {

  final testQuiz = Quiz(
    title: 'Quiz Test từ Flutter',
    content: 'Đây là nội dung quiz test',
    userId: 1,
  );

  final testImagePath = "C:\\Users\\HP\\Pictures\\Screenshots\\Screenshot 2025-05-13 125518.png";
  final testImage = File(testImagePath);

  if (!await testImage.exists()) {
    print('Ảnh test không tồn tại tại đường dẫn: $testImagePath');
    return;
  }

  print('Bắt đầu test tạo quiz...');

  try {
    final quizService = QuizApiService();
    final result = await quizService.createQuiz(testQuiz, testImage);

    print('Tạo quiz thành công!');
    print('Kết quả trả về:');
    print(result);
  } catch (e) {
    print('Lỗi khi tạo quiz:');
    print(e.toString());
  }
}