import 'package:feedback_gitlab/feedback_gitlab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lerlingua/user_interface/settings/credentials_dialog.dart';
import 'package:lerlingua/user_interface/settings/settings_page.dart';
import 'package:lerlingua/user_interface/learn/learn.dart';
import 'package:lerlingua/user_interface/read/read.dart';
import 'package:lerlingua/resources/database/mirror/mirror_sync_extension.dart';
import '../global_variables/global_variables.dart';
import '../resources/event_bus.dart';
import '../resources/database/mirror/mirror.dart';
import '../resources/settings/settings.dart';
import 'cards/cards.dart';

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
        body:
            <Widget>[
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
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              !Settings().showFeedbackButton ? SizedBox.shrink() : Positioned(
                left: 4,
                bottom: 11,
                child: IconButton(
                  icon: const Icon(Icons.feedback),
                  color: Theme.of(context).colorScheme.secondary,
                  tooltip: 'Give Feedback',
                  onPressed: () {
                    try {
                      BetterFeedback.of(context).showAndUploadToGitLab(
                        projectId: gitlabProjectId,
                        apiToken: feedbackToken,
                        gitlabUrl: gitlabUrl,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
              ),
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
                      angle:
                          -_controller.value *
                          2.0 *
                          3.14159, // Rotate in radians
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
  }
}
