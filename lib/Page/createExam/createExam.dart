import 'package:flutter/material.dart';
import 'package:quizapp_fe/Page/createExam/QuestionScreen.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({Key? key}) : super(key: key);

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  int _selectedImageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCFBCFF), Color(0xFFE6E6FF)],
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFAB47BC), Color(0xFFCE93D8)],
                      ),
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: _buildAppBar(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThongTinCoBan(),
                        const SizedBox(height: 16),
                        _buildImagePreview(),
                        const SizedBox(height: 16),
                        _buildImageSelector(),
                        const SizedBox(height: 32),
                        _buildTenDeThiField(),
                        const SizedBox(height: 24),
                        _buildMoTaDeThiField(),
                        const SizedBox(
                            height:
                            80), // Add extra space to avoid overlap with the fixed button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildLuuButton(), // Fixed "Lưu" button at the bottom
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.8),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () {
                // Handle back button press
              },
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Tạo đề thi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Maintain balance
        ],
      ),
    );
  }

  Widget _buildThongTinCoBan() {
    return const Text(
      'Thông tin cơ bản',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333366),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 2),
        image: const DecorationImage(
          image: NetworkImage(
              'https://ahaslides.com/wp-content/uploads/2020/08/SEO939-thumb.webp'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildUploadImageOption(),
        _buildImageOption(1),
        _buildImageOption(2),
        _buildImageOption(3),
      ],
    );
  }

  Widget _buildUploadImageOption() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey.shade400, width: 1, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.camera_alt,
          size: 30,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildImageOption(int index) {
    final bool isSelected = _selectedImageIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImageIndex = index;
        });
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage('assets/images/exam_option_$index.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isSelected
            ? Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.indigo,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildTenDeThiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Tên đề thi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333366),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'VD: Đề thi Tiếng Anh chuyên ngành 1',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoTaDeThiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Mô tả đề thi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333366),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập mô tả cho đề thi...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLuuButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white, // White background similar to header
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF5E5CE6), Color(0xFF7B68EE)],
        ),
      ),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionScreen(),));
            // Handle save button press
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Lưu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
