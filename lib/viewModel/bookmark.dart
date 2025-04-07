import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkManager extends ChangeNotifier {
  List<Map<String, dynamic>> _bookmarkedWords = [];

  List<Map<String, dynamic>> get bookmarkedWords => _bookmarkedWords;

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('bookmarks');
    if (data != null) {
      List<dynamic> jsonList = jsonDecode(data);
      _bookmarkedWords = List<Map<String, dynamic>>.from(jsonList);
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(Map<String, dynamic> word) async {
    bool exists = _bookmarkedWords.any((w) => w['word'] == word['word']);
    if (exists) {
      _bookmarkedWords.removeWhere((w) => w['word'] == word['word']);
    } else {
      _bookmarkedWords.add(word);
    }
    notifyListeners();
    await _saveToStorage();
  }

  bool isBookmarked(String word) {
    return _bookmarkedWords.any((w) => w['word'] == word);
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(_bookmarkedWords);
    await prefs.setString('bookmarks', data);
  }
}
