import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/wordRepository.dart';
import '../viewModel/bookmark.dart';
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
  bool showBookmarksOnly = false;


  @override
  void initState() {
    super.initState();
    wordsFuture = WordRepository().getAllWords();
    searchController.addListener(onSearchChanged);

    wordsFuture.then((words) {
      setState(() {
        allWords = words;
        filteredWords = words;
      });
    });
  }

  void onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredWords = allWords
          .where((word) => word['word'].toLowerCase().contains(query))
          .toList();

      if (showBookmarksOnly) {
        filteredWords = filteredWords.where((word) {
          return context.read<BookmarkManager>().isBookmarked(word['word']);
        }).toList();
      }
    });
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
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Tìm kiếm từ...",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: showBookmarksOnly,
                            onChanged: (bool? value) {
                              setState(() {
                                showBookmarksOnly = value!;
                                onSearchChanged(); // Apply filter after state change
                              });
                            },
                          ),
                          Text("Chỉ hiển thị từ đã đánh dấu")
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      var word = filteredWords[index];
                      bool isBookmarked = context.watch<BookmarkManager>().isBookmarked(word['word']);

                      return ListTile(
                        title: Text(
                          word['word'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(word['pos']),
                        trailing: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.amber : null,
                          ),
                          onPressed: () {
                            context.read<BookmarkManager>().toggleBookmark(word);
                          },
                        ),
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
    bool isBookmarked = context.watch<BookmarkManager>().isBookmarked(word['word']);

    return Scaffold(
      appBar: AppBar(
        title: Text(word['word']),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : null,
            ),
            onPressed: () {
              context.read<BookmarkManager>().toggleBookmark(word);
            },
          ),
        ],
      ),
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
