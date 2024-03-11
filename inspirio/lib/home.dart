import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspirio/pages/homepage.dart';
import 'package:inspirio/pages/poetry.dart';
import 'package:inspirio/status/screens/home_screen.dart';
import 'pages/category.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final List<Widget?> _pages;

  int selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = List.generate(4, (_) => null);
    _initializePage(0);
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: IndexedStack(
        index: selectedPageIndex,
        children: _pages.map((page) {
          if (page == null) {
            return Container();
          } else {
            return page;
          }
        }).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: backgroundColour,
        selectedIndex: selectedPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            selectedPageIndex = index;
            if (_pages[index] == null) {
              _initializePage(index);
            }
          });
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: primaryColour,
            ),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.chat, color: primaryColour),
            icon: Icon(Icons.chat_outlined),
            label: 'Status',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.format_quote, color: primaryColour),
            icon: Icon(Icons.format_quote_outlined),
            label: 'Quotes',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history_edu, color: primaryColour),
            icon: Icon(Icons.history_edu_outlined),
            label: 'Poetry',
          ),
        ],
      ),
    );
  }

  void _initializePage(int index) {
    switch (index) {
      case 0:
        _pages[index] = const InspirioHome();
        break;
      case 1:
        _pages[index] = const InspirioStatusSaver();
        break;
      case 2:
        _pages[index] = const Category();
        break;
      case 3:
        _pages[index] = const PoetryPage();
        break;
      default:
        throw Exception('Invalid index');
    }
  }
}
