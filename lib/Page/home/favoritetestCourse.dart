import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/details/details.dart';
import 'package:quizapp_fe/Page/favoriteCourse.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/model/favorite_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteTestsCarousel extends StatefulWidget {
  const FavoriteTestsCarousel({Key? key}) : super(key: key);

  @override
  _FavoriteTestsCarouselState createState() => _FavoriteTestsCarouselState();
}

class _FavoriteTestsCarouselState extends State<FavoriteTestsCarousel> {
  late FavoriteApi favoriteApi;
  int? _userId;
  List<Map<String, dynamic>> dsfavorite = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    favoriteApi = FavoriteApi();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      try {
        AccountApi accountApi = AccountApi();
        final user = await accountApi.checkUsername(username);
        setState(() {
          _userId = user.id;
        });
        _fetchFavorites();
      } catch (e) {
        setState(() {
          errorMessage = 'Lỗi khi tải thông tin người dùng: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Vui lòng đăng nhập để xem danh sách yêu thích';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final favorites = _userId != null ? await favoriteApi.getFavoritesByUserId(_userId!) : <Map<String, dynamic>>[];
      setState(() {
        dsfavorite = favorites != null
            ? favorites.map((item) => Map<String, dynamic>.from(item)).toList()
            : <Map<String, dynamic>>[];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải danh sách yêu thích: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoriteCourses()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Xem thêm'),
              ),
              const Text(
                'Đề thi yêu thích',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200, // Giới hạn chiều cao tối đa
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          )
              : dsfavorite.isEmpty
              ? const Center(child: Text('Chưa có đề thi yêu thích'))
              : ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: dsfavorite.length > 5 ? 5 : dsfavorite.length,
            itemBuilder: (context, index) {
              final test = dsfavorite[index];
              // Debug log để kiểm tra dữ liệu
              print('Test item $index: $test');
              if (test == null || test.isEmpty) {
                return const SizedBox.shrink();
              }
              return InkWell(
                onTap: () {
                  if (test['id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuizDetailPage(idquiz: test['id']),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ID không hợp lệ')),
                    );
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: test['image'] != null &&
                              test['image'].isNotEmpty &&
                              test['image'] is String
                              ? Image.network(
                            '${BaseUrl.urlImage}${test['image']}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error,
                                stackTrace) =>
                                Image.asset(
                                  'assets/images/quiz/title.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                          )
                              : Image.asset(
                            'assets/images/quiz/title.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test['title'] != null && test['title'] is String
                                    ? test['title']
                                    : 'No title',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                test['numberquiz'] != null &&
                                    test['numberquiz'] is num
                                    ? '${test['numberquiz']} câu'
                                    : '0 câu',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: test['imageUser'] != null &&
                                          test['imageUser'].isNotEmpty &&
                                          test['imageUser'] is String
                                          ? Image.network(
                                        '${BaseUrl.urlImage}${test['imageUser']}',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                            stackTrace) =>
                                            Image.asset(
                                              'assets/images/quiz/title.png',
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                          : Image.asset(
                                        'assets/images/quiz/title.png',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    test['userName'] != null && test['userName'] is String
                                        ? test['userName']
                                        : 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}