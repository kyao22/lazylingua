import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? _user;

  // Hàm đăng nhập bằng Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '306752994500-pjdmbunaud0rb2l072mr3keqd3u31oim.apps.googleusercontent.com',  // Thêm Web Client ID ở đây
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // Người dùng hủy đăng nhập

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        _user = userCredential.user;
      });
    } catch (e) {
      print("Lỗi đăng nhập: $e");
    }
  }

  // Hàm đăng xuất
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: Center(
        child: _user == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Chưa đăng nhập", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: Icon(Icons.login),
              label: Text("Đăng nhập bằng Google"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_user!.photoURL ?? ""),
              radius: 40,
            ),
            SizedBox(height: 10),
            Text("Xin chào, ${_user!.displayName}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_user!.email ?? "", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: Icon(Icons.logout),
              label: Text("Đăng xuất"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
