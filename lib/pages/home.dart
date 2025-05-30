import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lerlingua/pages/settings/credentials_dialog.dart';
import 'package:lerlingua/pages/settings/settings_page.dart';
import 'package:lerlingua/pages/learn/learn.dart';
import 'package:lerlingua/pages/read/read.dart';
import 'package:lerlingua/resources/database/mirror_sync_extension.dart';
import '../resources/event_bus.dart';
import '../resources/database/mirror.dart';
import 'list/list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
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

  Future<void> syncData() async {
    setState(() {
      _isSyncing = true;
    });
    _controller.repeat(); // Start rotation animation
    String syncResult = await Mirror().sync();
    setState(() {
      _isSyncing = false;
    });
    _controller.stop(); // Stop animation
    _controller.reset();
    // Show the Snackbar after synchronization
    if (!mounted) {
      if (kDebugMode) {
        print('Not mounted, cannot show snackbar.');
      }
      return;
    }
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
              icon: Icon(Icons.local_library_rounded),
              label: 'Read',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_rounded),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.ballot_rounded),
              label: 'Cards',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
        floatingActionButton: Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton.small(
              onPressed: _isSyncing ? null : syncData,
              tooltip: 'Sync',
              shape: const CircleBorder(),
              elevation: 0,
              //backgroundColor: Mirror().undoList.isEmpty ? null : Theme.of(context).colorScheme.error,
              child: AnimatedBuilder(
                animation: _controller,
                child: Icon(Icons.sync_rounded),
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
