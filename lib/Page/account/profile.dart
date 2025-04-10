import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
                  // Ảnh nền
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/home/imageHome2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white.withOpacity(0.7), // chỉnh opacity tuỳ ý
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 60.0),
                    child: const Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.school_outlined, size: 30, color: Colors.blueAccent),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'vvuvu vuvu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
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
                        Positioned(
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
                      onTap: () {},
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
                      onTap: () {},
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
                          const Text('Tiếng Việt', style: TextStyle(color: Colors.black54)),
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
                      text: " Đăng xuất ",

                      trailing: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_sunny, size: 20, color: Colors.black54),
                          SizedBox(width: 8),
                          Text('Sáng', style: TextStyle(color: Colors.black54)),
                          SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: () {},
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
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
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
          'assets/images/mascot_bottom.png',
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
}
