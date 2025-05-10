import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/QuestionButton.dart';


class TestResultScreen extends StatelessWidget {
  const TestResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final correctAnswers = [7, 8, 13, 15, 20];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFFBBA9E1), Color(0xFFF7BFD3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          // Handle back navigation
                        },
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Chi tiết phần thi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Balance the back button
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Result card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Score section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Score box
                              Container(
                                width: 100,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      '1.92',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Điểm',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Đúng: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      Text(
                                        '5 câu',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1BC45D),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Sai: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      Text(
                                        '21 câu',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFFF3B30),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Test details
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Thời gian làm: 00:01:50',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                'Số câu: 26 câu',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 1),

                        // Question grid
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: GridView.builder(
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: 26,
                              itemBuilder: (context, index) {
                                final questionNumber = index + 1;
                                final isCorrect =
                                correctAnswers.contains(questionNumber);

                                return QuestionButton(
                                  number: questionNumber,
                                  isHighlighted:
                                  false, // Không highlight câu nào
                                  status: isCorrect ? 'correct' : 'incorrect',
                                  borderColor: isCorrect
                                      ? const Color(0xFF1BC45D)
                                      : const Color(0xFFFF3B30),
                                  onTap: null, // Có thể thêm hành động nếu cần
                                );
                              },
                            ),
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
    );
  }
}


