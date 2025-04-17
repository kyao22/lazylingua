import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

// Hàm hiển thị modal - đặt trong file riêng
void showCustomModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return CustomModalContent();
    },
  );
}

// Widget cho nội dung modal có tích hợp trang dịch
class CustomModalContent extends StatefulWidget {
  const CustomModalContent({Key? key}) : super(key: key);

  @override
  State<CustomModalContent> createState() => _CustomModalContentState();
}

class _CustomModalContentState extends State<CustomModalContent> {
  final TextEditingController _controller = TextEditingController();
  String _translatedText = '';
  final translator = GoogleTranslator();
  bool _isEnglishToVietnamese = true; // true: en → vi, false: vi → en

  void _translateText() async {
    final inputText = _controller.text.trim();
    if (inputText.isNotEmpty) {
      final fromLang = _isEnglishToVietnamese ? 'en' : 'vi';
      final toLang = _isEnglishToVietnamese ? 'vi' : 'en';

      var translation = await translator.translate(inputText, from: fromLang, to: toLang);
      setState(() {
        _translatedText = translation.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header modal với nút đóng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trình Dịch Ngôn Ngữ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'X',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nội dung của modal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút chuyển đổi ngôn ngữ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isEnglishToVietnamese
                            ? 'Tiếng Anh → Tiếng Việt'
                            : 'Tiếng Việt → Tiếng Anh',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEnglishToVietnamese = !_isEnglishToVietnamese;
                            _translatedText = '';
                            _controller.clear();
                          });
                        },
                        icon: const Icon(Icons.swap_horiz),
                        tooltip: 'Chuyển chiều dịch',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TextField nhập văn bản
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Nhập văn bản',
                      border: const OutlineInputBorder(),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _translatedText = '';
                          });
                        },
                      )
                          : null,
                    ),
                    maxLines: 5,
                    onChanged: (value) => setState(() {}), // nút clear khi có nội dung
                  ),

                  const SizedBox(height: 12),

                  // Nút dịch
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _translateText,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Dịch', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hiển thị kết quả dịch
                  const Text(
                    'Bản dịch:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _translatedText.isEmpty
                          ? 'Bản dịch sẽ hiện ở đây'
                          : _translatedText,
                      style: const TextStyle(fontSize: 18),
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
