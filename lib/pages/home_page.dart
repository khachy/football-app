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
          NavigationDestination(
            icon: Image.asset(
              'assets/league.png',
              height: 20,
              color: Colors.black26,
            ),
            label: 'League',
            selectedIcon: Image.asset(
              'assets/league.png',
              height: 20,
              color: Colors.black,
            ),
          ),
          NavigationDestination(
            icon: Image.asset(
              'assets/favorite.png',
              height: 20,
              color: Colors.black26,
            ),
            label: 'Favorite',
            selectedIcon: Image.asset(
              'assets/favorite.png',
              height: 20,
              color: Colors.black,
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
