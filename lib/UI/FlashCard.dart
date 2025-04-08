import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    List<String> files = [
      'assets/Json/a.json',
      'assets/Json/b.json',
      'assets/Json/c.json',
      'assets/Json/d.json',
      'assets/Json/e.json',
      'assets/Json/f.json',
      'assets/Json/g.json',
      'assets/Json/h.json',
      'assets/Json/i.json',
      'assets/Json/j.json',
      'assets/Json/k.json',
      'assets/Json/l.json',
      'assets/Json/m.json',
      'assets/Json/n.json',
      'assets/Json/o.json',
      'assets/Json/p.json',
      'assets/Json/q.json',
      'assets/Json/r.json',
      'assets/Json/s.json',
      'assets/Json/t.json',
      'assets/Json/u.json',
      'assets/Json/v.json',
      'assets/Json/w.json',
      'assets/Json/x.json',
      'assets/Json/y.json',
      'assets/Json/z.json',
    ];

    List<dynamic> loadedWords = [];
    for (String file in files) {
      String data = await rootBundle.loadString(file);
      List<dynamic> words = jsonDecode(data);
      loadedWords.addAll(words);
    }

    setState(() {
      allWords = loadedWords;
      pickRandomWord(); // lấy từ ngẫu nhiên khi load xong
    });
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final definition = currentWord['senses'][0]['definition'];
    final phonetic = currentWord['phonetic_text'] ?? '';

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.greenAccent,
            title: Text("Flash Cards", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25))),
      body: Stack(
        children: [
          // ẢNH NỀN
          Positioned.fill(
            child: Image.asset(
              'assets/images/hinh-nen-nau-pastel.jpg', // Đường dẫn ảnh trong thư mục assets
              fit: BoxFit.cover,
            ),
          ),

          // CÁC THÀNH PHẦN GIAO DIỆN
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showAnswer = !showAnswer;
                      });
                    },
                    child: Card(
                      shadowColor: Colors.green,
                      elevation: 10,
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
                              Text("Tap this card to reveal", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            pickRandomWord();
                          });
                        },
                        icon: Icon(Icons.next_plan),
                        label: Text("Next word"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
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