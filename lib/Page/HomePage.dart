import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/infor.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == 4) {
      setState(() {
        _selectedIndex = 4;
      });
      print("index: $index");
      print("select: $_selectedIndex");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage()),
      );
      setState(() {
        _selectedIndex = 0; // Quay về "Trang chủ" nếu muốn
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.blue[100],
              child: const Center(child: Text('Phần banner hoặc nội dung đầu')),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuItem(Icons.star, 'Bảng xếp hạng'),
                _buildMenuItem(Icons.edit, 'Đề thi'),
                _buildMenuItem(Icons.book, 'Ví sử dụng'),
                _buildMenuItem(Icons.message, 'Kênh đề'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuItem(Icons.class_, 'Lớp học tập'),
                _buildMenuItem(Icons.school, 'Phòng thi'),
                _buildMenuItem(Icons.abc, 'Kết quả của tói'),
                _buildMenuItem(Icons.download, 'Đề thi tải xuổng'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              color: Colors.pink[100],
              child: const Center(child: Text('Nội dung khác')),
            ),
            Container(
              height: 300,
              color: Colors.green[100],
              child: const Center(child: Text('Nội dung khác')),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Kênh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }





  Widget _buildMenuItem(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: Icon(icon, size: 30, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80, // Giới hạn chiều rộng
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip, // Tránh ellipsis
          ),
        ),
      ],
    );
  }
}
