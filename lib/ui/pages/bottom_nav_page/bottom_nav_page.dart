import 'package:flutter/material.dart';

import 'package:youtube_clone/ui/styles/styles.dart';
import 'package:youtube_clone/ui/pages/bottom_nav_page/widgets/bottom_nav_bar.dart';

import 'package:youtube_clone/ui/pages/home_page/home_page.dart';
import 'package:youtube_clone/ui/pages/library_page/library_page.dart';
import 'package:youtube_clone/ui/pages/community_page/community_page.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage();

  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [];

  final _tabs = [
    BottomNavItem(
      title: 'Home',
      activeIcon: Icons.home,
      icon: Icons.home_outlined,
      child: const HomePage(),
    ),
    BottomNavItem(
      title: 'Library',
      activeIcon: Icons.video_library,
      icon: Icons.video_library_outlined,
      child: const LibraryPage(),
    ),
    BottomNavItem(
      title: 'Community',
      activeIcon: Icons.people_alt,
      icon: Icons.people_alt_outlined,
      child: const CommunityPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: Container(
        color: context.c.background,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar: BottomNavBar(
              tabs: _tabs,
              currentIndex: _selectedIndex,
              onSelect: (index) {
                _saveNavigationHistory(index);
                _selectTab(index);
              },
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: _tabs.map((t) => t.page).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNavigationHistory(int tappedIndex) {
    final previousIndex = _selectedIndex;
    _navigationHistory.add(previousIndex);
    if (_navigationHistory.contains(tappedIndex)) {
      _navigationHistory.remove(tappedIndex);
    }
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) {
      // Navigate to the first route of the tab.
      _tabs[index].key.currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Future<bool> _onBackButtonPressed() async {
    // If the route cannot be popped, we are on the first route of the tab.
    final isFirstRouteInCurrentTab =
        !await _tabs[_selectedIndex].key.currentState.maybePop();

    // Do no pop if we are not on the first route of the tab.
    if (!isFirstRouteInCurrentTab) return false;

    // If the _navigationHistory is empty,
    // Either exit the app
    // Or go to the first tab.
    if (_navigationHistory.isEmpty) {
      if (_selectedIndex == 0) return true;

      _selectTab(0);
      return false;
    }

    // If the _navigationHistory is not empty,
    // Navigate to the previous tab in history.
    final nextTab = _navigationHistory.removeLast();
    _selectTab(nextTab);
    return false;
  }
}
