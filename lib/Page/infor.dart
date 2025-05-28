import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/HomePage.dart';
import 'package:quizapp_fe/Page/account/change_password.dart';
import 'package:quizapp_fe/Page/account/login.dart';
import 'package:quizapp_fe/Page/account/profile.dart';
import 'package:quizapp_fe/Page/discoverCourse.dart';
import 'package:quizapp_fe/helpers/Url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
  String name = "Noname";
  String imageUrl = "unknown.png";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
      setState(() {
        _selectedIndex = 4;
      });
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DiscoverCourse()),
      );
      await _loadUsername();
      setState(() {
        _selectedIndex = index;
      });
    }else if(index == 1){
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DiscoverCourse()),
      );
    }else if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChangePasswordPage()),
      );
      setState(() {
        _selectedIndex = index;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? avatar = prefs.getString('avatar_path');
    print('Loaded username: $username, avatar: $avatar'); // Debug

    setState(() {
      name = username ?? "Noname";
      imageUrl = avatar ?? "unknown.png";
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color listBackgroundColor = Colors.white;
    const Color headingColor = Colors.black54;
    const Color iconColor = Colors.black54;
    const Color textColor = Colors.black87;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/home/imageHome2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 60.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: imageUrl != "unknown.png"
                                  ? ClipOval(
                                child: Image.network(
                                  "${BaseUrl.urlImage}/$imageUrl",
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.school_outlined,
                                    size: 30,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              )
                                  : const Icon(
                                Icons.school_outlined,
                                size: 30,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Học sinh/ sinh viên',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Positioned(
                          right: -5,
                          top: -15,
                          child: SizedBox(
                            height: 85,
                            width: 85,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Cá nhân',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: listBackgroundColor,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.person_outline,
                      text: 'Chỉnh sửa thông tin',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalInfoScreen(),
                          ),
                        );
                        await _loadUsername(); // Tải lại dữ liệu sau khi quay lại
                      },
                      iconColor: iconColor,
                      textColor: textColor,
                    ),
                    _buildSettingsItem(
                      icon: Icons.card_giftcard,
                      text: 'Mã nhận thưởng',
                      onTap: () {},
                      iconColor: iconColor,
                      textColor: textColor,
                    ),
                    _buildSettingsItem(
                      icon: Icons.lock_outline,
                      text: 'Thay đổi mật khẩu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(),
                          ),
                        );
                      },
                      iconColor: iconColor,
                      textColor: textColor,
                    ),
                    _buildSettingsItem(
                      icon: Icons.language,
                      text: 'Ngôn ngữ',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: const NetworkImage(
                              'https://hoanghamobile.com/tin-tuc/wp-content/uploads/2017/06/gg-1.jpg',
                            ),
                            backgroundColor: Colors.transparent,
                            onBackgroundImageError: (exception, stackTrace) {
                              print('Error loading flag image: $exception');
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text('Tiếng Việt',
                              style: TextStyle(color: Colors.black54)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: () {},
                      iconColor: iconColor,
                      textColor: textColor,
                    ),
                    _buildSettingsItem(
                      icon: Icons.offline_share,
                      text: "Đăng xuất",
                      trailing: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: () async {
                        await showDialogLogout(context);
                      },
                      iconColor: iconColor,
                      textColor: Colors.red,
                      hideDivider: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildContactUsSection(context),
              const SizedBox(height: 20),
              const SizedBox(height: 80),
            ]),
          ),
        ],
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    Widget? trailing,
    required VoidCallback onTap,
    required Color iconColor,
    required Color textColor,
    bool hideDivider = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ),
                trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          if (!hideDivider)
            Divider(
              height: 1,
              thickness: 1,
              indent: 55,
              color: Colors.grey[200],
            ),
        ],
      ),
    );
  }

  Widget _buildContactUsSection(BuildContext context) {
    Widget bottomMascot = Positioned(
      right: 10,
      bottom: -20,
      child: SizedBox(
        height: 100,
        width: 100,
        child: Image.asset(
          'assets/images/home/imageHome2.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            size: 50,
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Liên hệ chúng tôi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Góp ý của bạn rất quan trọng với chúng tôi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Liên hệ',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          bottomMascot,
        ],
      ),
    );
  }

  Future<void> showDialogLogout(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc muốn đăng xuất không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Không', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Có', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('isLoggedIn');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}