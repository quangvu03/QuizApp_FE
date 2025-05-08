import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/QuestionButton.dart';


class QuestionSelectionScreen extends StatefulWidget {
  const QuestionSelectionScreen({Key? key}) : super(key: key);

  @override
  State<QuestionSelectionScreen> createState() =>
      _QuestionSelectionScreenState();
}

class _QuestionSelectionScreenState extends State<QuestionSelectionScreen> {
  int seconds = 23;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9E8CC1), Color(0xFFCAB8E8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar with back button and timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon:
                      const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Placeholder to balance the layout
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Question selection container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Header with title and close button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Chọn câu hỏi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // Grid of question numbers
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: 48,
                            itemBuilder: (context, index) {
                              final questionNumber = index + 1;
                              return QuestionButton(
                                number: questionNumber,
                                isHighlighted: questionNumber == 1,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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


