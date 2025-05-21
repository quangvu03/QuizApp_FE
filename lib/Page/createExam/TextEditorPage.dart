import 'package:flutter/material.dart';

class TextEditorPage extends StatefulWidget {
  const TextEditorPage({Key? key, required String initialContent}) : super(key: key);

  @override
  State<TextEditorPage> createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final TextEditingController _textController = TextEditingController();
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header với nút quay lại và xác nhận
          Container(
            padding:
            const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCFBEFF), Color(0xFFBFB0F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                  onPressed: () {
                    // Xử lý sự kiện khi nhấn nút quay lại
                  },
                ),
                const Text(
                  "Nhập nội dung",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện khi nhấn nút xác nhận
                  },
                  child: const Text("Xác nhận"),
                  style: ElevatedButton.styleFrom(
                    overlayColor: const Color(0xFF5E5CE6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Phần soạn thảo
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Thanh công cụ định dạng
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Hàng 1: Normal, Bold, Italic, Underline
                        Row(
                          children: [
                            // Dropdown Normal
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: const [
                                  Text(
                                    "Normal",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Bold
                            IconButton(
                              icon: const Icon(Icons.format_bold),
                              onPressed: () {
                                setState(() {
                                  isBold = !isBold;
                                });
                              },
                              color: isBold
                                  ? const Color(0xFF5E5CE6)
                                  : Colors.black,
                            ),
                            // Italic
                            IconButton(
                              icon: const Icon(Icons.format_italic),
                              onPressed: () {
                                setState(() {
                                  isItalic = !isItalic;
                                });
                              },
                              color: isItalic
                                  ? const Color(0xFF5E5CE6)
                                  : Colors.black,
                            ),
                            // Underline
                            IconButton(
                              icon: const Icon(Icons.format_underline),
                              onPressed: () {
                                setState(() {
                                  isUnderline = !isUnderline;
                                });
                              },
                              color: isUnderline
                                  ? const Color(0xFF5E5CE6)
                                  : Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Hàng 2: Division, X², X₂, A̲, Format, Bullet, Numbered List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Division
                            IconButton(
                              icon: const Text("÷",
                                  style: TextStyle(fontSize: 24)),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút phép chia
                              },
                            ),
                            // X²
                            IconButton(
                              icon: const Text("X²",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút bình phương
                              },
                            ),
                            // X₂
                            IconButton(
                              icon: const Text("X₂",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút chỉ số dưới
                              },
                            ),
                            // A̲ (A underline)
                            IconButton(
                              icon: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text("A", style: TextStyle(fontSize: 18)),
                                  Positioned(
                                    bottom: 0,
                                    child: Icon(Icons.minimize, size: 14),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút gạch chân chữ
                              },
                            ),
                            // Highlight
                            IconButton(
                              icon: const Icon(Icons.format_color_fill),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút tô màu
                              },
                            ),
                            // Bullet List
                            IconButton(
                              icon: const Icon(Icons.format_list_bulleted),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút danh sách dấu chấm
                              },
                            ),
                            // Numbered List

                          ],
                        ),
                        const SizedBox(height: 8),

                        // Hàng 3: Link, Image
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.format_list_numbered),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút danh sách số
                              },
                            ),
                            // Link
                            IconButton(
                              icon: const Icon(Icons.link),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút chèn liên kết
                              },
                            ),
                            // Image
                            IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: () {
                                // Xử lý sự kiện khi nhấn nút chèn hình ảnh
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Vùng soạn thảo văn bản
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(
                        fontWeight:
                        isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                        isItalic ? FontStyle.italic : FontStyle.normal,
                        decoration: isUnderline
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Nhập nội dung",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // Indicator ở cuối trang (dấu gạch ngang)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
