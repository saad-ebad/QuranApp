import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quran_app/screens/parah_screen.dart';

import '../widgets/bottom_bar.dart';
import 'bookmark_screen.dart';
import 'collections.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of screens corresponding to each bottom navigation item
  final List<Widget> _screens = [
    const HomeScreen(),
     CollectionsScreen(),
    const ParahScreen(),
    const HomeScreen(), // Assuming this is your Mushaf screen
    const BookmarkScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}