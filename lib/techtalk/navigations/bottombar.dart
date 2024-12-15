import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtalk/techtalk/screens/home.dart';
import 'package:techtalk/techtalk/screens/search.dart';
import 'package:techtalk/techtalk/screens/userprofile.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Home(),
    LikedVideosScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            elevation: 10,
            selectedItemColor: const Color.fromARGB(255, 0, 255, 8),
            unselectedItemColor: Colors.white,
            unselectedLabelStyle: GoogleFonts.inter(),
            selectedLabelStyle: GoogleFonts.protestRevolution(fontWeight: FontWeight.bold),
            items: <BottomNavigationBarItem>[
              _buildNavigationBarItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavigationBarItem(
                icon: Icons.favorite,
                label: 'likedVideos',
                index: 1,
              ),
              _buildNavigationBarItem(
                icon: Icons.person,
                label: 'Profile',
                index: 2,
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: Matrix4.diagonal3Values(
          _selectedIndex == index ? 1.2 : 1.0,
          _selectedIndex == index ? 1.2 : 1.0,
          1.0,
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}