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
      appBar: AppBar(title: const Text("Chat with AI bot")),
      body: Column(
        children: [
          Expanded(
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Ask anything..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
