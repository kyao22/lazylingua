import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  ProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text("No user signed in"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar (ảnh đại diện)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user?.photoURL ?? 'https://www.gravatar.com/avatar/?d=mp'),
              ),
              SizedBox(height: 16),

              // Tên người dùng
              Text(
                "Name: ${user?.displayName ?? 'N/A'}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Email người dùng
              Text(
                "Email: ${user?.email ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              Spacer(),
              // Nút đăng xuất
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text("Sign Out", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
