import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/wordRepository.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> allWords = [];
  late Map<String, dynamic> currentQuestion;
  List<String> options = [];
  String? selectedOption;
  bool showResult = false;

  int currentStreak = 0;
  int highestStreak = 0;

  @override
  void initState() {
    super.initState();
    loadWords();
    loadHighestStreak();
  }

  Future<void> loadHighestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestStreak = prefs.getInt('highestStreak') ?? 0;
    });
  }

  Future<void> saveHighestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highestStreak', highestStreak);
  }

  Future<void> loadWords() async {
    List<dynamic> words = await WordRepository().getAllWords();
    setState(() {
      allWords = words
          .where((word) => word['senses'] != null && word['senses'].isNotEmpty)
          .toList();
    });
    generateQuestion();
  }

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
        if (currentStreak > highestStreak) {
          highestStreak = currentStreak;
          saveHighestStreak();
        }
      } else {
        currentStreak = 0;
      }
    });
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
      appBar: AppBar(title: Text("Mini Quiz")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔥 Streak: $currentStreak    🏆 Best: $highestStreak",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
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
    );
  }
}