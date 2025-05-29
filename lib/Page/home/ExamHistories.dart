import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/exam/QuizResultDetails.dart';
import 'package:quizapp_fe/entities/Takeanswer.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:quizapp_fe/model/Takeanswer_api.dart';
import 'package:quizapp_fe/model/account_api.dart';
import 'package:quizapp_fe/helpers/Toast_helper.dart';
import 'package:quizapp_fe/model/quiz_api.dart';
import 'package:quizapp_fe/model/take_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamHistories extends StatefulWidget {
  const ExamHistories({Key? key}) : super(key: key);

  @override
  State<ExamHistories> createState() => _ExamHistoriesState();
}

class _ExamHistoriesState extends State<ExamHistories> {
  final TakeApi _takeApi = TakeApi();
  final AccountApi accountApi = AccountApi();
  List<Map<String, dynamic>> _takes = [];
  bool _isLoading = true;
  String? _username;
  List<Map<String, dynamic>>? examQuizList;
  List<TakeAnswer>? listTake;


  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      try {
        final user = await accountApi.checkUsername(username);
        setState(() {
          _username =
              user.userName; // Use user.userName to ensure valid username
        });
        _loadTakes();
        
      } catch (e) {
        print("Error loading user: $e");
        ToastHelper.showError("Không thể tải thông tin người dùng");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("usernull");
      ToastHelper.showError("Vui lòng đăng nhập lại");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTakes() async {
    if (_username == null) return;
    try {
      final takes = await _takeApi.getTakesByUserName(_username!);
      setState(() {
        _takes = takes ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading takes: $e");
      ToastHelper.showError("Không thể tải danh sách bài kiểm tra");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchAPIexam(int idquiz) async {
    QuizApiService examapi = QuizApiService();
    try {
      final result = await examapi.getExam(idquiz);
      print("result:: $result");
      if (result != null && result["examQuizDTO"] is List) {
        setState(() {
          examQuizList = (result["examQuizDTO"] as List)
              .cast<Map<String, dynamic>>(); // Ép kiểu List<dynamic> thành List<Map<String, dynamic>>
        });
      } else {
        ToastHelper.showError("Không thể tải danh sách câu hỏi");
      }
    } catch (e) {
      ToastHelper.showError("Lỗi khi lấy dữ liệu: $e");
    }
  }
  Future<void> fetchTakeAnswersByTakeId(int takeId) async {
    try {
      TakeAnswerApi _takeApi = TakeAnswerApi();
      final result = await _takeApi.fetchTakeAnswersByTakeId(takeId);
      if (result != null) {
        setState(() {
          listTake = result;
        });
      } else {
        ToastHelper.showError("Không có dữ liệu trả về từ API");
      }
    } catch (e) {
      ToastHelper.showError("Lỗi khi lấy dữ liệu: $e");
      print("Error fetching take answers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8B4F0),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.grey),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Kết quả của tôi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildTab('Ôn thi', true),
                    _buildTab('Thi thử', false),
                    _buildTab('Bài tập', false),
                    _buildTab('Phòng thi', false),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kết quả các đề thi bạn đã làm ở chế độ Ôn thi',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _takes.isEmpty
                                  ? const Center(
                                      child: Text('Không có kết quả nào'))
                                  : ListView.builder(
                                      itemCount: _takes.length,
                                      itemBuilder: (context, index) {
                                        final take = _takes[index];
                                        final score = (10 /
                                                take['numberquiz'] *
                                                take['correct'])
                                            .toStringAsFixed(2);
                                        final correct =
                                            take['correct'].toString();
                                        final wrong = (take['numberquiz'] -
                                                take['correct'])
                                            .toString();
                                        final status = double.parse(score) < 4
                                            ? 'Yếu'
                                            : (double.parse(score) < 6
                                                ? 'Trung bình'
                                                : 'Tốt');
                                        final statusColor =
                                            double.parse(score) < 4
                                                ? const Color(0xFFE53E3E)
                                                : (double.parse(score) < 6
                                                    ? Colors.orange
                                                    : Colors.green);

                                        return GestureDetector(
                                            onTap: () async {
                                              final takeId = take['takeId'];
                                              final time = take['time'];
                                              final totalQuestion = take['numberquiz'];
                                              final countCorrect = take['correct'];
                                              final quizId = take['quizId'];


                                              await fetchTakeAnswersByTakeId(takeId);
                                              await fetchAPIexam(quizId);


                                              if (takeId != null && listTake != null && examQuizList != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => QuizResultScreen(
                                                      totalQuestion,
                                                      countCorrect,
                                                      time,
                                                      listTake!,
                                                      examQuizList!,
                                                      takeId,
                                                      quizId,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                print('Dữ liệu chưa được tải đầy đủ hoặc takeId không hợp lệ');
                                              }
                                            },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                // Header with Status
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(16),
                                                      topRight:
                                                          Radius.circular(16),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),

                                                // Content
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(16),
                                                      bottomRight:
                                                          Radius.circular(16),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      // Title and Score
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 60,
                                                            height: 60,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              gradient:
                                                                  const LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFF4FC3F7),
                                                                  Color(
                                                                      0xFFFFB74D),
                                                                ],
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              child:
                                                                  Image.network(
                                                                '${BaseUrl.urlImage}${take['image']}',
                                                                width: 60,
                                                                height: 60,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    color: Colors
                                                                        .grey,
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .quiz,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 30,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  take['title']
                                                                      .toString()
                                                                      .toUpperCase(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Người dùng: ${take['userName']}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  statusColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  score,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  'Điểm',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // Device and Mode
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 12,
                                                              vertical: 6,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            child: const Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .smartphone,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                SizedBox(
                                                                    width: 4),
                                                                Text(
                                                                  'Mobile',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 12,
                                                              vertical: 6,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            child: const Text(
                                                              'Ôn thi',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // Time and Date
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .access_time,
                                                                color: Colors
                                                                    .purple,
                                                                size: 16,
                                                              ),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                take['time'],
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .purple,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Spacer(),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .calendar_today,
                                                                color: Colors
                                                                    .purple,
                                                                size: 16,
                                                              ),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                take['finishedAt']
                                                                    .substring(
                                                                        0, 16)
                                                                    .replaceAll(
                                                                        'T',
                                                                        ' '),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .purple,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Image.network(
                                                                '${BaseUrl.urlImage}${take['imageUser']}',
                                                                width: 24,
                                                                height: 24,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Container(
                                                                    width: 24,
                                                                    height: 24,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .blue,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .person,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 16,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // Progress Bar
                                                      Container(
                                                        width: double.infinity,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          gradient:
                                                              const LinearGradient(
                                                            colors: [
                                                              Color(0xFFE8B4F0),
                                                              Color(0xFF64B5F6),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Số câu đã làm: ${take['numberquiz']}/${take['numberquiz']}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // Statistics
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                _buildStatCard(
                                                              'Đúng',
                                                              correct,
                                                              Colors.green,
                                                              Icons
                                                                  .check_circle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child:
                                                                _buildStatCard(
                                                              'Sai',
                                                              wrong,
                                                              const Color(
                                                                  0xFFE53E3E),
                                                              Icons.cancel,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child:
                                                                _buildStatCard(
                                                              'Bỏ trống',
                                                              '0',
                                                              Colors.orange,
                                                              Icons.warning,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )),
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

  Widget _buildTab(String title, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
