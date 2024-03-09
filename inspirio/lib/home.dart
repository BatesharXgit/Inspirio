import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspirio/pages/homepage.dart';
import 'package:inspirio/pages/poetry.dart';
import 'package:inspirio/status/screens/home_screen.dart';

import 'pages/category.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const numOfTabs = 2;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedPageIndex = 0;

  final List<Widget> _pages = [
    const InspirioHome(),
    const InspirioStatusSaver(),
    const Category(),
    const PoetryPage(),
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
          ],
        ),
      ),
    );
  }
}
