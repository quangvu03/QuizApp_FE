import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  var takeApi;
  Map<String, dynamic>? dataAchievement;
  int _selectedTab = 0;
  bool _dataLoaded = false;

  @override
  void initState() {
    takeApi = TakeApi();
    print("initState called");
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (_dataLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      try {
        final user = await accountApi.checkUsername(username);
        print("User ID: ${user.id}");
        print("User data: $user");
        setState(() {
          _username = user.userName;
        });
        await Future.wait([
          _loadTakes(),
          fetchdataAchivement(user.id),
        ]);
        setState(() {
          _isLoading = false;
          _dataLoaded = true;
        });
        print("Load user completed, _isLoading: $_isLoading, dataAchievement: $dataAchievement");
      } catch (e) {
        print("Error loading user: $e");
        ToastHelper.showError("Không thể tải thông tin người dùng");
        setState(() {
          _isLoading = false;
          _dataLoaded = true;
        });
      }
    } else {
      print("usernull");
      ToastHelper.showError("Vui lòng đăng nhập lại");
      setState(() {
        _isLoading = false;
        _dataLoaded = true;
      });
    }
  }

  Future<void> _loadTakes() async {
    if (_username == null) return;
    try {
      final takes = await _takeApi.getTakesByUserName(_username!);
      setState(() {
        _takes = takes ?? [];
      });
      print("Takes data: $_takes");
      print("Takes count: ${_takes.length}");
    } catch (e) {
      print("Error loading takes: $e");
      ToastHelper.showError("Không thể tải danh sách bài kiểm tra");
      setState(() {
        _takes = [];
      });
    }
  }

  Future<void> fetchAPIexam(int idquiz) async {
    QuizApiService examapi = QuizApiService();
    try {
      final result = await examapi.getExam(idquiz);
      if (result != null && result["examQuizDTO"] is List) {
        setState(() {
          examQuizList = (result["examQuizDTO"] as List).cast<Map<String, dynamic>>();
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

  Future<void> fetchdataAchivement(var userId) async {
    if (userId == null) {
      print("fetchdataAchivement: User ID is null");
      ToastHelper.showError("Không thể tải thành tựu: User ID không hợp lệ");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final data = await takeApi.getAchievement(userId);
      print("Achievement data: $data");
      print("Achievement data type: ${data.runtimeType}");
      if (data != null) {
        setState(() {
          dataAchievement = data;
          _isLoading = false;
        });
        print("dataAchievement set to: $dataAchievement");
      } else {
        print("fetchdataAchivement: Data is null or not a Map");
        ToastHelper.showError("Không có dữ liệu thành tựu");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching achievement: $e");
      ToastHelper.showError("Không thể tải thành tựu: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _prepareChartData() {
    print("Preparing chart data, takes count: ${_takes.length}");
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    for (var take in _takes) {
      try {
        String date = take['finishedAt']?.substring(0, 10) ?? '';
        if (date.isEmpty) {
          print("Invalid finishedAt for take: $take");
          continue;
        }
        double score = (10 / (take['numberquiz'] ?? 1) * (take['correct'] ?? 0));
        String time = take['time'] ?? '00:00:00';
        List<String> timeParts = time.split(':');
        int seconds = int.parse(timeParts[0]) * 3600 +
            int.parse(timeParts[1]) * 60 +
            int.parse(timeParts[2]);

        if (!groupedByDate.containsKey(date)) {
          groupedByDate[date] = [];
        }
        groupedByDate[date]!.add({
          'score': score,
          'timeSeconds': seconds,
        });
      } catch (e) {
        print("Error processing take: $take, error: $e");
        continue;
      }
    }

    List<Map<String, dynamic>> chartData = [];
    groupedByDate.forEach((date, takes) {
      double avgScore =
          takes.fold(0.0, (sum, take) => sum + take['score']) / takes.length;
      double avgTimeSeconds =
          takes.fold(0.0, (sum, take) => sum + take['timeSeconds']) / takes.length;
      chartData.add({
        'date': date,
        'avgScore': avgScore,
        'avgTimeSeconds': avgTimeSeconds,
      });
    });

    chartData.sort((a, b) => a['date'].compareTo(b['date']));
    print("Chart data: $chartData");
    return chartData;
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
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildTab('Ôn thi', _selectedTab == 0, () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    }),
                    _buildTab('Thống kê', _selectedTab == 1, () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    }),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Giảm padding để mở rộng
                  child: _selectedTab == 0 ? _buildExamTab() : _buildStatsTab(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }

  Widget _buildExamTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kết quả các đề thi bạn đã làm',
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
                  ? const Center(child: Text('Không có kết quả nào'))
                  : ListView.builder(
                      itemCount: _takes.length,
                      itemBuilder: (context, index) {
                        final take = _takes[index];
                        final score = (10 / (take['numberquiz'] ?? 1) * (take['correct'] ?? 0)).toStringAsFixed(2);
                        final correct = (take['correct'] ?? 0).toString();
                        final wrong = ((take['numberquiz'] ?? 0) - (take['correct'] ?? 0)).toString();
                        final status = double.parse(score) < 4
                            ? 'Yếu'
                            : (double.parse(score) < 6 ? 'Trung bình' : 'Tốt');
                        final statusColor = double.parse(score) < 4
                            ? const Color(0xFFE53E3E)
                            : (double.parse(score) < 6 ? Colors.orange : Colors.green);

                        return GestureDetector(
                          onTap: () async {
                            final takeId = take['takeId'];
                            final time = take['time'] ?? '00:00:00';
                            final totalQuestion = take['numberquiz'] ?? 0;
                            final countCorrect = take['correct'] ?? 0;
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
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    status,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF4FC3F7),
                                                  Color(0xFFFFB74D),
                                                ],
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                '${BaseUrl.urlImage}${take['image'] ?? ''}',
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey,
                                                    child: const Icon(
                                                      Icons.quiz,
                                                      color: Colors.white,
                                                      size: 30,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (take['title'] ?? '').toString().toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  'Người dùng: ${take['userName'] ?? ''}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  score,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Text(
                                                  'Điểm',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.smartphone,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Mobile',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Text(
                                              'Ôn thi',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                color: Colors.purple,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                take['time'] ?? '00:00:00',
                                                style: const TextStyle(
                                                  color: Colors.purple,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                color: Colors.purple,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                (take['finishedAt'] ?? '').substring(0, 16).replaceAll('T', ' '),
                                                style: const TextStyle(
                                                  color: Colors.purple,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Image.network(
                                                '${BaseUrl.urlImage}${take['imageUser'] ?? ''}',
                                                width: 24,
                                                height: 24,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFE8B4F0),
                                              Color(0xFF64B5F6),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Số câu đã làm: ${take['numberquiz'] ?? 0}/${take['numberquiz'] ?? 0}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              'Đúng',
                                              correct,
                                              Colors.green,
                                              Icons.check_circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildStatCard(
                                              'Sai',
                                              wrong,
                                              const Color(0xFFE53E3E),
                                              Icons.cancel,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildStatCard(
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
                    ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (dataAchievement == null) {
      return const Center(child: Text('Không có dữ liệu thống kê'));
    }

    int totalCorrect = _takes.fold(0, (sum, take) => sum + ((take['correct'] as num?)?.toInt() ?? 0));
    int totalQuestions = _takes.fold(0, (sum, take) => sum + ((take['numberquiz'] as num?)?.toInt() ?? 0));
    double correctPercentage = totalQuestions > 0 ? (totalCorrect / totalQuestions * 100) : 0;

    List<Map<String, dynamic>> chartData = _prepareChartData();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê kết quả',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatCardLarge(
            'Tổng số bài làm',
            dataAchievement!['totalTake']?.toString() ?? '0',
            Colors.blue,
            Icons.quiz,
          ),
          const SizedBox(height: 16),
          _buildStatCardLarge(
            'Điểm trung bình',
            (dataAchievement!['avgScore'] as num?)?.toStringAsFixed(2) ?? '0.00',
            Colors.purple,
            Icons.star,
          ),
          const SizedBox(height: 16),
          _buildStatCardLarge(
            'Thời gian trung bình',
            dataAchievement!['avgtime']?.toString() ?? '00:00:00',
            Colors.orange,
            Icons.access_time,
          ),
          const SizedBox(height: 16),
          _buildStatCardLarge(
            'Tỷ lệ đúng',
            '${correctPercentage.toStringAsFixed(1)}%',
            Colors.teal,
            Icons.pie_chart,
          ),
          const SizedBox(height: 20),
          const Text(
            'Biểu đồ điểm và thời gian theo ngày',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, // Mở rộng chiều rộng toàn màn hình
            height: 300, // Giữ chiều cao
            child: chartData.isEmpty
                ? const Center(child: Text('Không có dữ liệu biểu đồ'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) =>
                                Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                          ),
                          axisNameWidget: const Text('Điểm', style: TextStyle(color: Colors.blue)),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) =>
                                Text('${(value).toInt()}m', style: const TextStyle(fontSize: 10)),
                          ),
                          axisNameWidget: const Text('Thời gian', style: TextStyle(color: Colors.red)),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= chartData.length) return const Text('');
                              return Text(
                                chartData[index]['date'].substring(5),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                          axisNameWidget: const Text('Ngày'),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value['avgScore']))
                              .toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: chartData
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value['avgTimeSeconds'] / 60))
                              .toList(),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      minX: 0,
                      maxX: chartData.length - 1.0,
                      minY: 0,
                      maxY: chartData
                          .map((e) => (e['avgScore'] as double) > (e['avgTimeSeconds'] as double) / 60
                              ? e['avgScore']
                              : e['avgTimeSeconds'] / 60)
                          .reduce((a, b) => a > b ? a : b)
                          .ceil()
                          .toDouble(),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                spot.y.toStringAsFixed(1) + (spot.barIndex == 0 ? ' điểm' : ' phút'),
                                TextStyle(color: spot.barIndex == 0 ? Colors.blue : Colors.red),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardLarge(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
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
            ],
          ),
        ],
      ),
    );
  }
}