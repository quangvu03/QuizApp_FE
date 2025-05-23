import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class TextEditorPage extends StatefulWidget {
  final String? initialContent; // Nhận Delta JSON dưới dạng chuỗi

  const TextEditorPage({super.key, this.initialContent});

  @override
  State<TextEditorPage> createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    late Document doc;

    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        // Phân tích Delta JSON nếu có
        final deltaJson = jsonDecode(widget.initialContent!);
        doc = Document.fromJson(deltaJson);
      } catch (e) {
        // Nếu JSON không hợp lệ, dùng văn bản thuần
        doc = Document();
        doc.insert(0, widget.initialContent!);
      }
    } else {
      doc = Document();
    }

    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cắt ảnh',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cắt ảnh',
            cancelButtonTitle: 'Hủy',
            doneButtonTitle: 'Xong',
          ),
        ],
      );

      if (croppedFile != null) {
        final bytes = await File(croppedFile.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final imageUrl = 'data:image/jpeg;base64,$base64Image';

        final index = _controller.selection.baseOffset;
        _controller.document.insert(index, BlockEmbed.image(imageUrl));
        _controller.updateSelection(
          TextSelection.collapsed(offset: index + 1),
          ChangeSource.local,
        );
      }
    }
  }

  void _saveAndReturn() {
    // Trả về Delta JSON trực tiếp từ document
    final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
    print("detal: " +deltaJson);
    Navigator.pop(context, deltaJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soạn thảo văn bản'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndReturn,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveAndReturn, // Lưu và trả về Delta JSON
                  label: const Text("Lưu"),
                  icon: const Icon(Icons.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _controller.document = Document();
                    _controller.updateSelection(
                      const TextSelection.collapsed(offset: 0),
                      ChangeSource.local,
                    );
                  },
                  label: const Text("reset"),
                  icon: const Icon(Icons.import_export_rounded),
                  // ...
                ),
                ElevatedButton.icon(
                  onPressed: _pickAndCropImage,
                  label: const Text("Chèn ảnh"),
                  icon: const Icon(Icons.image),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _controller,
              multiRowsDisplay: true,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  autoFocus: false,
                  scrollable: true,
                  padding: EdgeInsets.zero,
                  expands: true,
                ),
                scrollController: ScrollController(),
                focusNode: _focusNode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}