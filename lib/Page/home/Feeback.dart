import 'package:flutter/material.dart';

class FeedbackCarousel extends StatefulWidget {
  const FeedbackCarousel({Key? key}) : super(key: key);

  @override
  _FeedbackCarouselState createState() => _FeedbackCarouselState();
}

class _FeedbackCarouselState extends State<FeedbackCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> feedbacks = [
      {
        'name': 'Phạm Minh Khôi',
        'role': 'Thí sinh tự do',
        'content':
        'Ca nhân thay app rất phù hợp với những thí sinh tự do như mình. Có thể tự lên kế hoạch ôn tập, tự chọn môn học, tự làm đề, nói chung là chủ động hoàn toàn...',
        'image': 'assets/images/user1.png', // Thay bằng đường dẫn hình ảnh thực tế
      },
      {
        'name': 'Nguyễn Thị Hồng',
        'role': 'Học sinh lớp 12',
        'content':
        'App giúp mình cải thiện kỹ năng làm bài rất nhiều. Các đề thi sát với thực tế và có giải thích chi tiết.',
        'image': 'assets/images/user2.png', // Thay bằng đường dẫn hình ảnh thực tế
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phản hồi của người dùng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180, // Chiều cao của carousel
          child: PageView.builder(
            controller: _pageController,
            itemCount: feedbacks.length,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: AssetImage(feedbacks[index]['image']),
                      child: feedbacks[index]['image'] == null
                          ? const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            feedbacks[index]['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedbacks[index]['role'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feedbacks[index]['content'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
            feedbacks.length,
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