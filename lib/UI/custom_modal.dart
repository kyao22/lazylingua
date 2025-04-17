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

  void _translateText() async {
    final inputText = _controller.text.trim();
    if (inputText.isNotEmpty) {
      var translation = await translator.translate(inputText, from: 'en', to: 'vi');
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
                  'Dịch Tiếng Anh → Tiếng Việt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Nút X để đóng modal
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
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

          // Nội dung của modal - Trang dịch
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Nhập tiếng Anh',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5, // Cho phép nhập nhiều dòng
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _translateText,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Dịch', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bản dịch:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _translatedText.isEmpty ? 'Bản dịch sẽ hiện ở đây' : _translatedText,
                      style: TextStyle(fontSize: 18),
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