import 'package:flutter/material.dart';
import 'package:lerlingua/pages/settings/settings_widget.dart';
import 'package:lerlingua/pages/learn/learn.dart';
import 'package:lerlingua/pages/read/read.dart';
import 'package:lerlingua/resources/mirror_sync_extension.dart';
import '../resources/event_bus.dart';
import '../resources/mirror.dart';
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
        body: <Widget>[
          Read(),
          Learn(),
          ListPage(),
          SettingsWidget(),
        ][currentPageIndex],
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
        floatingActionButton: currentPageIndex > 2
            ? null
            : Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton.small(
              onPressed: () async {
                await Mirror().sync();
                // Fire LearningPage event
                LearningPageNewDataEvent event = LearningPageNewDataEvent();
                eventBus.fire(event);
              },
              tooltip: 'Sync',
              shape: const CircleBorder(),
              elevation: 0,
              child: Icon(Icons.sync_outlined),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
  }
}
