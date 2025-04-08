import 'package:flutter/material.dart';
import '../viewModel/chat_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final chatService = ChatService("AIzaSyDMMj0WhdkG7UZ2E26SZHVfJ6edylwtBB8");

  @override
  bool get wantKeepAlive => true; // Giữ trạng thái khi chuyển tab

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('chat_history');
    if (jsonString != null) {
      final List<dynamic> data = jsonDecode(jsonString);
      setState(() {
        _messages.clear();
        _messages.addAll(data.cast<Map<String, String>>());
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_messages);
    await prefs.setString('chat_history', jsonString);
  }

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
    });
    _saveMessages(); // Lưu sau khi người dùng gửi

    _controller.clear();

    try {
      final response = await chatService.sendMessage(text);
      setState(() {
        _messages.add({'role': 'ai', 'text': response.trim()});
      });
      _saveMessages(); // Lưu sau khi nhận phản hồi từ AI
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Lỗi: $e'});
      });
      _saveMessages(); // Lưu lỗi nếu có
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Bắt buộc khi dùng KeepAlive
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/nen.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: kToolbarHeight,
                margin: EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Chat with AI bot",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Remove the title since we're using flexibleSpace
            title: null,
          ),
        ),
      ),
      body: Container(
        // Add background image for the entire screen
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/nen.png'), // Change to your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // KHUNG CHỨA TRÒ CHUYỆN VỚI NỀN LÀ ẢNH
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/nen3.png'),
                    fit: BoxFit.cover,
                    opacity: 0.5, // Adjustable opacity for background image
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade300, width: 2.0), // Added blue border here
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (_, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg['text'] ?? ""),
                      ),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "You ask lazy will answer 🦥",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          )

        ],
      ),),
    );
  }
}
