import 'package:flutter/material.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:quizapp_fe/Page/details/details.dart';

class ListCourseByUserScreen extends StatefulWidget {
  final String Username;
  final bool showOption;

  const ListCourseByUserScreen({super.key, required this.Username,
    this.showOption = false,
  } );

  @override
  _ListCourseByUserScreenState createState() => _ListCourseByUserScreenState();
}

class _ListCourseByUserScreenState extends State<ListCourseByUserScreen> {
  String selectedFilter = 'newest';
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> dataCourse = [];
  bool isLoading = true;
  String errorMessage = '';


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      QuizApiService quizApiService = QuizApiService();
      final courses = await quizApiService.fetchQuizzesByUsername(widget.Username);
      setState(() {
        dataCourse = courses;
        _sortData();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  void _sortData() {
    setState(() {
      if (selectedFilter == 'popular') {
        dataCourse.sort((a, b) => (b['numberquiz'] as int).compareTo(a['numberquiz'] as int));
      } else {
        dataCourse.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
      }
    });
  }

  void search(String value) {
    setState(() {
      if (value.isEmpty) {
        _fetchData(); // Tải lại toàn bộ dữ liệu nếu search rỗng
      } else {
        dataCourse = dataCourse
            .where((course) => (course['title'] as String)
            .toLowerCase()
            .contains(value.toLowerCase()))
            .toList();
        _sortData(); // Sắp xếp lại sau khi lọc
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/bgrhome2.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white70,
              BlendMode.overlay,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Danh sách đề thi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black54,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: search,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đề thi...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white),
                  ),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = 'newest';
                              _sortData();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedFilter == 'newest'
                                  ? Colors.pink[300]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.access_time, color: Colors.white, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Mới nhất',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = 'popular';
                              _sortData();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedFilter == 'popular'
                                  ? Colors.pink[300]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Nổi bật nhất',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
                    : dataCourse.isEmpty
                    ? const Center(
                  child: Text(
                    'Không tìm thấy đề',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dataCourse.length,
                  itemBuilder: (context, index) {
                    final course = dataCourse[index];
                    return InkWell(
                      onTap: () {
                        print('showOption: ${widget.showOption}');
                        // Điều hướng đến trang chi tiết, tương tự discoverCourse.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizDetailPage(idquiz: course['id'], showOption: widget.showOption,),
                          ),
                        );
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
                                child: course['image'] != null && course['image'].isNotEmpty
                                    ? Image.network(
                                  '${BaseUrl.urlImage}${course['image']}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
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
                                      course['title'] ?? 'No title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${course['numberquiz'] ?? 0} câu',
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
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundImage: NetworkImage(
                                              '${BaseUrl.urlImage}${course['imageUser']}',
                                            ),
                                            backgroundColor: Colors.grey[200],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          course['userName'] ?? 'Unknown',
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
          ),
        ),
      ),
    );
  }
}