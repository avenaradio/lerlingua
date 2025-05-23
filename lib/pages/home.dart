import 'package:flutter/material.dart';
import 'package:lerlingua/pages/settings/credentials_dialog.dart';
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

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int currentPageIndex = 1;
  bool _isSyncing = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });
    _controller.repeat(); // Start rotation animation

    String syncResult = await Mirror().sync();

    // Show the Snackbar after synchronization
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(syncResult),
        action: (syncResult) {
          switch (syncResult) {
            case 'Synchronization successful':
              return null; // No action for successful sync
            case 'Bad credentials':
              return SnackBarAction(
                label: 'Edit',
                onPressed: () {
                  // Enter credentials
                  CredentialsDialog().show(context);
                },
              );
            default:
              return SnackBarAction(
                label: 'See log',
                onPressed: () {
                  // Go to settings tab
                  setState(() {
                    currentPageIndex = 3;
                  });
                },
              );
          }
        }(syncResult), // Call the function with syncResult
      ),
    );

    // Fire LearningPage event
    LearningPageNewDataEvent event = LearningPageNewDataEvent();
    eventBus.fire(event);

    setState(() {
      _isSyncing = false;
    });
    _controller.stop(); // Stop animation
  }

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
        floatingActionButton: Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton.small(
              onPressed: _isSyncing ? null : _syncData,
              tooltip: 'Sync',
              shape: const CircleBorder(),
              elevation: 0,
              child: AnimatedBuilder(
                animation: _controller,
                child: Icon(Icons.sync_outlined),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: - _controller.value * 2.0 * 3.14159, // Rotate in radians
                    child: child,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
  }
}
