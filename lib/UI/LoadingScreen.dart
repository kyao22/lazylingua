import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../viewModel/bookmark.dart';
import '../viewModel/steak_manager.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    await Future.delayed(Duration(seconds: 2)); // Hiệu ứng splash

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.isAnonymous) {
      // Đăng nhập rồi, load dữ liệu nếu cần
      await context.read<BookmarkManager>().loadFromFirebase();
      await context.read<StreakManager>().loadStreakFromFirestore();
      Navigator.pushReplacementNamed(context, '/dictionary');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/images/Frame 9809.png"),
      ),
    );
  }
}
