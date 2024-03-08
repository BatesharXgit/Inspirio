import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:inspirio/pages/homepage.dart';
import 'package:inspirio/pages/poetry.dart';
import 'package:inspirio/util/settings.dart';

import 'pages/category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedPageIndex = 0;

  final List<Widget> _pages = [
    InspirioHome(),
    Center(
      child: Text(
        'Unlearn 🐛',
      ),
    ),
    Category(),
    PoetryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspirio',
      home: Scaffold(
        body: IndexedStack(
          index: selectedPageIndex,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedPageIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.chat),
              icon: Icon(Icons.chat_outlined),
              label: 'Status',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.format_quote),
              icon: Icon(Icons.format_quote_outlined),
              label: 'Quotes',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.history_edu),
              icon: Icon(Icons.history_edu_outlined),
              label: 'Poetry',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outline),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
