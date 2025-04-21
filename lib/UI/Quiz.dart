import 'dart:math';
import 'dart:ui';  // Thêm import này cho ImageFilter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewModel/steak_manager.dart';

class QuizScreen extends StatefulWidget {
  final List<dynamic> words;
  const QuizScreen({Key? key, required this.words}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> allWords = [];
  late Map<String, dynamic> currentQuestion;
  List<String> options = [];
  String? selectedOption;
  bool showResult = false;
  StreakManager streakManager = StreakManager();

  int currentStreak = 0;
  int highestStreak = 0;

  @override
  void initState() {
    super.initState();
    allWords = widget.words
        .where((word) => word['senses'] != null && word['senses'].isNotEmpty)
        .toList();
    _loadStreakData();
    generateQuestion();
  }

  Future<void> _loadStreakData() async {
    // Đợi dữ liệu streak được tải về trước khi tiếp tục
    await streakManager.loadStreak();
    setState(() {
      // Sau khi tải xong, bạn có thể cập nhật lại currentStreak và highestStreak
      currentStreak = streakManager.currentStreak;
      highestStreak = streakManager.highestStreak;
    });
  }

  /*Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestStreak = prefs.getInt('highestStreak') ?? 0;
      currentStreak = prefs.getInt('currentStreak') ?? 0;
    });
  }

  Future<void> saveHighestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highestStreak', highestStreak);
  }

  Future<void> saveCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', currentStreak);
  }

  Future<void> saveStreakToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final highestStreak = prefs.getInt('highestStreak') ?? 0;
    final currentStreak = prefs.getInt('currentStreak') ?? 0;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await docRef.set({
      'highestStreak': highestStreak,
      'currentStreak': currentStreak,
    }, SetOptions(merge: true));
  }

  Future<void> loadStreakFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        setState(() {
          highestStreak = data['highestStreak'] ?? 0;
          currentStreak = data['currentStreak'] ?? 0;
        });
      }
    }
  }*/

  void generateQuestion() {
    if (allWords.length < 4) return;

    final random = Random();
    final correctWord = allWords[random.nextInt(allWords.length)];
    final correctAnswer = correctWord['word'];

    final senses = correctWord['senses'];
    final definition = senses[random.nextInt(senses.length)]['definition'];

    Set<String> wrongOptions = {};
    while (wrongOptions.length < 3) {
      String word = allWords[random.nextInt(allWords.length)]['word'];
      if (word != correctAnswer) {
        wrongOptions.add(word);
      }
    }

    List<String> allOptions = [correctAnswer, ...wrongOptions];
    allOptions.shuffle();

    setState(() {
      currentQuestion = {
        'definition': definition,
        'correctAnswer': correctAnswer,
      };
      options = allOptions;
      selectedOption = null;
      showResult = false;
    });
  }

  void checkAnswer(String answer) async {
    bool isCorrect = answer == currentQuestion['correctAnswer'];

    setState(() {
      selectedOption = answer;
      showResult = true;

      if (isCorrect) {
        currentStreak++;
        streakManager.saveCurrentStreak(currentStreak);
        if (currentStreak > highestStreak) {
          highestStreak = currentStreak;
          streakManager.saveHighestStreak(highestStreak);
        }
      } else {
        currentStreak = 0;
      }
    });
  }

  // Thêm hàm getStreakFlameColor() ở đây
  Color getStreakFlameColor() {
    if (currentStreak < 10) {
      return Colors.orange; // Màu cam bình thường cho streak < 10
    } else if (currentStreak < 20) {
      return Colors.red; // Màu đỏ cho streak 10-19
    } else if (currentStreak < 30) {
      return Colors.blue; // Màu xanh dương cho streak 20-29
    } else if (currentStreak < 40) {
      return Colors.green; // Màu xanh lá cho streak 30-39
    } else if (currentStreak < 50) {
      return Colors.purpleAccent.shade700; // Màu tiím cho streak 40-49
    } else {
      return Colors.purple.shade900; // Màu tím đậm cho streak >= 50
    }
  }

  Widget buildStreakDisplay() {
    // Xác định màu dựa trên streak trực tiếp tại đây
    Color flameColor;
    if (currentStreak < 10) {
      flameColor = Colors.orange;
    } else if (currentStreak < 20) {
      flameColor = Colors.red;
    } else if (currentStreak < 30) {
      flameColor = Colors.blue;
    } else if (currentStreak < 40) {
      flameColor = Colors.green;
    } else if (currentStreak < 50) {
      flameColor = Colors.purpleAccent.shade700;
    } else {
      flameColor = Colors.purple.shade900;
    }

    String streakText = "";

    // Thay đổi cả văn bản và emoji dựa trên streak
    if (currentStreak < 10) {
      streakText = "🔥 Streak: $currentStreak";
    } else if (currentStreak < 20) {
      streakText = "🔥🔥 Hot streak: $currentStreak";
    } else if (currentStreak < 30) {
      streakText = "🔥🔥🔥 Super streak: $currentStreak";
    } else if (currentStreak < 40) {
      streakText = "🔥🔥🔥🔥 Ultra streak: $currentStreak";
    } else if (currentStreak < 50) {
      streakText = "🔥🔥🔥🔥🔥 Mega streak: $currentStreak";
    } else {
      streakText = "🔥🔥🔥🔥🔥🔥 LEGENDARY: $currentStreak";
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            streakText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: flameColor,  // Màu của văn bản thay đổi
            ),
          ),
        ),
        Text(
          "🏆 Best: $highestStreak",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildOption(String option) {
    bool isCorrect = option == currentQuestion['correctAnswer'];
    Color color;

    if (!showResult) {
      color = Colors.grey.shade200;
    } else if (option == selectedOption) {
      color = isCorrect ? Colors.green : Colors.red;
    } else if (isCorrect) {
      color = Colors.green;
    } else {
      color = Colors.grey.shade200;
    }

    return Card(
      color: color,
      child: ListTile(
        title: Text(option),
        onTap: showResult ? null : () => checkAnswer(option),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allWords.isEmpty || currentQuestion.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Mini Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  "Mini Quiz",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: null,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ẢNH NỀN
          Positioned.fill(
            child: Image.asset(
              'assets/images/anhbautroi.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildStreakDisplay(), // Sử dụng widget tùy chỉnh cho streak
                SizedBox(height: 16),
                Text(
                  "Definition:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentQuestion['definition'],
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 24),
                ...options.map((opt) => buildOption(opt)).toList(),
                SizedBox(height: 20),
                if (showResult)
                  Center(
                    child: ElevatedButton(
                      onPressed: generateQuestion,
                      child: Text("Next"),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}