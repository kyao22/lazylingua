import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late Future<List<dynamic>> wordsFuture;
  List<dynamic> allWords = [];
  List<dynamic> filteredWords = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    wordsFuture = loadAllWords();
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredWords = allWords
          .where((word) => word['word'].toLowerCase().contains(query))
          .toList();
    });
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

    List<dynamic> all = [];

    for (String file in files) {
      String data = await rootBundle.loadString(file);
      List<dynamic> words = jsonDecode(data);
      all.addAll(words);
    }

    setState(() {
      allWords = all;
      filteredWords = allWords;
    });

    return all;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Dictionary", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold))),
      body: FutureBuilder<List<dynamic>>(
        future: wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải dữ liệu!"));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Tìm kiếm từ...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      var word = filteredWords[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordDetailScreen(word: word),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word['word'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  word['pos'],
                                  style: TextStyle(color: Colors.grey[900]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                    },
                  ),
                ),
              ],
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
                SizedBox(width: 10),
            Text(word['pos'], style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            SizedBox(height: 10),
            if (word['phonetic_text'] != null)
              Text("Phonetic: ${word['phonetic_text']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: word['senses'].length,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
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
