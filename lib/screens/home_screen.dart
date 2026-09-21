import 'package:flutter/material.dart';

import 'accueil/accueil_screen.dart';
import 'urgences/urgences_screen.dart';
import 'conseils/conseils_screen.dart';
import 'profil/profil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _ecrans = const [
    AccueilScreen(),
    UrgencesScreen(),
    ConseilsScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F3),

      body: IndexedStack(
        index: _index,
        children: _ecrans,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,

        backgroundColor: const Color(0xFF2B1B1B),

        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),

        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),

        showSelectedLabels: true,
        showUnselectedLabels: true,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            _index = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt),
            label: 'Urgences',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Conseils',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}