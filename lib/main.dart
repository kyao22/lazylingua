import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lazylingua/viewModel/steak_manager.dart';
import 'package:provider/provider.dart';
import 'package:lazylingua/UI/User.dart';
import 'UI/FlashCard.dart';
import 'UI/LoadingScreen.dart';
import 'UI/Quiz.dart';
import 'UI/login_screen.dart';
import 'UI/register_screen.dart';
import 'firebase_options.dart';
import '../UI/Dictionary.dart';
import '../viewModel/bookmark.dart';
import 'UI/chat_page.dart';
import 'model/wordRepository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BookmarkManager()..loadBookmarks(),
        ),
        ChangeNotifierProvider(
          create: (context) => StreakManager()..loadStreak(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => LoginScreen(),
        '/dictionary': (context) => HomePage(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  int _selectedIndex = 0;
  late Future<List<dynamic>> wordsFuture;
  StreakManager streakManager = StreakManager();


  // Danh sách các widget sẽ hiển thị tương ứng với từng nút.

  @override
  void initState() {
    super.initState();
    wordsFuture = WordRepository().getAllWords();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this); // Ngừng theo dõi khi bị huỷ
    // Đồng bộ khi rời khỏi app
    final bookmarkManager = Provider.of<BookmarkManager>(context, listen: false);
    bookmarkManager.saveToFirebase(FirebaseAuth.instance.currentUser!.uid); // Hàm bạn đã có trong BookmarkManager

    await streakManager.saveStreakToFirestore();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final bookmarkManager = Provider.of<BookmarkManager>(context, listen: false);
      bookmarkManager.saveToFirebase(FirebaseAuth.instance.currentUser!.uid); // Gửi lên Firebase khi app chuyển sang nền hoặc bị đóng

      await streakManager.saveStreakToFirestore();
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: wordsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Lỗi khi tải dữ liệu')));
        } else {
          final words = snapshot.data!;


          final _widgetOptions = [
            DictionaryScreen(words: words),
            FlashCardScreen(words: words),
            QuizScreen(words: words),
            ChatPage(),
            ProfileScreen(user: FirebaseAuth.instance.currentUser),
          ];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 50,
              title: Image.asset(
                "assets/images/logocuak.png",
                width: 400,
                height: 65,
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/nen.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
            bottomNavigationBar: BottomNavigationBar(
              iconSize: 30,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.black,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: 'Dictionary',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.flash_on),
                  label: 'Flash Card',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.quiz),
                  label: 'Quiz',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.android),
                  label: 'ChatBot',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
              ],
            ),
          );
        };
      },
    );
  }
}