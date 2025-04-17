import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/wordRepository.dart';
import '../viewModel/bookmark.dart';
import 'custom_modal.dart';


class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  double _xPosition = 20;
  double _yPosition = 20;
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
                  "Dictionary",
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
      body: Stack(
        children: [
          FutureBuilder<List<dynamic>>(
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
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueAccent)
                              ),
                              prefixIcon: Icon(Icons.search, color: Colors.blue,),
                            ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: showBookmarksOnly,
                                onChanged: (bool? value) {
                                  setState(() {
                                    showBookmarksOnly = value!;
                                    onSearchChanged();
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.blue, width: 1),),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
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

          // Ảnh tròn có thể di chuyển
          Positioned(
            left: _xPosition,
            top: _yPosition,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _xPosition = (_xPosition + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 60);
                  _yPosition = (_yPosition + details.delta.dy).clamp(0, 690 - 60);
                });
              },
              onTap: () {
                showCustomModal(context);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12), // Match border radius with container
                  child: Image.asset(
                    'assets/images/logodich.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ),
          ),
        ],
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
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
