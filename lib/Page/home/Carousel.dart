import 'package:flutter/material.dart';

class CourseCarousel extends StatefulWidget {
  const CourseCarousel({Key? key}) : super(key: key);

  @override
  _CourseCarouselState createState() => _CourseCarouselState();
}

class _CourseCarouselState extends State<CourseCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> courses = [
      {
        'title': 'CHINH PHỤC IELTS/SAT\nMỖI CĂN CỦA TƯƠNG LAI',
        'description': [
          'Bứt phá điểm số trong thời gian ngắn nhất',
          'Luyện đề chuyên sâu, chinh phục mọi dạng bài',
          'Hệ thống giáo dục chuẩn quốc tế',
        ],
        'image': 'assets/images/course_teacher.png', // Thay bằng đường dẫn hình ảnh thực tế
        'type': 'Đề đầu vào',
        'platform': 'Apollo',
      },
      {
        'title': 'KHÓA LUYỆN THI IELTS/SAT',
        'description': [
          'Học cùng giáo viên hàng đầu',
          'Lộ trình cá nhân hóa',
          'Cam kết đầu ra 7.0+',
        ],
        'image': 'assets/images/course_student.png', // Thay bằng đường dẫn hình ảnh thực tế
        'type': 'Đề đầu ra',
        'platform': 'Apollo',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Khóa học từ đối tác',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // Xử lý khi nhấn "Xem thêm"
              },
              child: const Text(
                'Xem thêm',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300, // Chiều cao của carousel
          child: PageView.builder(
            controller: _pageController,
            itemCount: courses.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBBDEFB), Color(0xFFE1BEE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              courses[index]['type'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            courses[index]['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...courses[index]['description'].map<Widget>((desc) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      desc,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(courses[index]['image']),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.school,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              courses[index]['platform'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            courses.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.pink : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}