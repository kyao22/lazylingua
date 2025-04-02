import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/dictionary_word_model.dart'; // Import model dữ liệu

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

Future<List<dynamic>> loadAllWords() async {
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

  List<dynamic> allWords = [];

  for (String file in files) {
    String data = await rootBundle.loadString(file);
    List<dynamic> words = jsonDecode(data);
    allWords.addAll(words);
  }

  return allWords;
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late Future<List<dynamic>> wordsFuture;

  @override
  void initState() {
    super.initState();
    wordsFuture = loadAllWords(); // Gọi hàm tải JSON
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dictionary")),
      body: FutureBuilder<List<dynamic>>(
        future: wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Đang tải
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải dữ liệu!")); // Báo lỗi
          } else {
            List<dynamic> words = snapshot.data!;
            return ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                var word = words[index];
                return ListTile(
                  title: Text(word['word'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(word['pos']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordDetailScreen(word: word),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class WordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> word;

  WordDetailScreen({required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(word['word'])),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word['word'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(word['pos'], style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            SizedBox(height: 10),
            if (word['phonetic_text'] != null)
              Text("Phonetic: ${word['phonetic_text']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: word['senses'].length,
                itemBuilder: (context, index) {
                  var sense = word['senses'][index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ${sense['definition']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sense['examples'].map<Widget>((example) {
                            return Padding(
                              padding: EdgeInsets.only(left: 16.0, top: 4.0),
                              child: Text("- ${example['x']}"),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}