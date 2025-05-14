import 'package:flutter/material.dart';
import 'package:lerlingua/pages/settings/settings_widget.dart';
import 'package:lerlingua/pages/learn/learn.dart';
import 'package:lerlingua/pages/read/read.dart';

import 'list/list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.book),
              label: 'Read',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline_rounded),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt),
              label: 'List',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        body:
        <Widget>[
          Read(),
          Learn(),
          ListPage(),
          SettingsWidget(),
        ][currentPageIndex],
      ),
    );
  }
}
