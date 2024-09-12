import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_app/screens/matches.dart';
// import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 60.h,
        elevation: 0,
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: Colors.white,
        shadowColor: Colors.black38,
        // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Image.asset(
              'assets/football-field.png',
              height: 20,
              color: Colors.black26,
              colorBlendMode: BlendMode.srcIn,
            ),
            label: 'Matches',
            selectedIcon: Image.asset(
              'assets/football-field.png',
              height: 20,
              color: Colors.black,
            ),
          ),
          const NavigationDestination(
            icon: Icon(
              Icons.shield_outlined,
              color: Colors.black26,
              size: 20,
            ),
            label: 'League',
            selectedIcon: Icon(
              Icons.shield_outlined,
              color: Colors.black,
              size: 20,
            ),
          ),
          const NavigationDestination(
            icon: Icon(
              Icons.favorite_outline_rounded,
              color: Colors.black26,
              size: 20,
            ),
            label: 'Favorite',
            selectedIcon: Icon(
              Icons.favorite_outline_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
          NavigationDestination(
            icon: Image.asset(
              'assets/news.png',
              height: 20,
              color: Colors.black26,
              colorBlendMode: BlendMode.srcIn,
            ),
            label: 'News',
            selectedIcon: Image.asset(
              'assets/news.png',
              height: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: screens[selectedIndex],
    );
  }
}

final screens = [
  const Matches(),
  Container(
    color: Colors.blue,
  ),
  Container(
    color: Colors.green,
  ),
  Container(
    color: Colors.yellow,
  ),
];
