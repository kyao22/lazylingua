import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lazylingua/UI/User.dart';
import 'UI/FlashCard.dart';
import 'UI/LoadingScreen.dart';
import 'UI/login_screen.dart';
import 'firebase_options.dart';
import '../UI/Dictionary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
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
        '/dictionary': (context) => HomePage(),}
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Danh sách các widget sẽ hiển thị tương ứng với từng nút.
  static final List<Widget> _widgetOptions = <Widget>[
    DictionaryScreen(),
    FlashCardScreen(),
    ProfileScreen(user: FirebaseAuth.instance.currentUser),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD81B60),
        title: Image.asset("assets/images/LazyLingua.png", width: 360, height: 50),
        titleSpacing: 50,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        backgroundColor : Colors.greenAccent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
