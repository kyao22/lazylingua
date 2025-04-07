import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/wordRepository.dart';
import '../viewModel/bookmark.dart';

class FlashCardScreen extends StatefulWidget {
  @override
  _FlashCardScreenState createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  List<dynamic> allWords = [];
  late dynamic currentWord;
  bool showAnswer = false;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    allWords = await WordRepository().getAllWords();
    pickRandomWord(); // chỉ gọi khi đã có dữ liệu
    setState(() {});
  }

  void pickRandomWord() {
    if (allWords.isNotEmpty) {
      currentWord = allWords[random.nextInt(allWords.length)];
      showAnswer = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allWords.isEmpty || currentWord == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Flash Cards")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final definition = currentWord['senses'][0]['definition'];
    final phonetic = currentWord['phonetic_text'] ?? '';
    bool isBookmarked = context.watch<BookmarkManager>().isBookmarked(currentWord['word']);

    return Scaffold(
      appBar: AppBar(title: Text("Flash Cards")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(24),
              width: double.infinity,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentWord['word'],
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  if (showAnswer) ...[
                    if (phonetic.isNotEmpty)
                      Text("Phonetic: $phonetic", style: TextStyle(fontSize: 20)),
                    SizedBox(height: 10),
                    Text("Meaning: $definition", style: TextStyle(fontSize: 18)),
                  ] else
                    Text("Tap 'Show Answer' to reveal", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => showAnswer = !showAnswer),
              child: Text("Show Answer"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  pickRandomWord();
                });
              },
              child: Text("Next"),
            ),
            ElevatedButton(
              onPressed: () {
                // Toggle bookmark for the current word
                context.read<BookmarkManager>().toggleBookmark(currentWord);
              },
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? Colors.amber : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}