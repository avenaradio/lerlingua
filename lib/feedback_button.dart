import 'package:feedback_gitlab/feedback_gitlab.dart';
import 'package:flutter/material.dart';

import 'global_variables.dart';

class FeedbackButton extends StatefulWidget {
  const FeedbackButton({super.key});

  @override
  FeedbackButtonState createState() => FeedbackButtonState();
}

class FeedbackButtonState extends State<FeedbackButton> {
  Offset position = Offset(8, 8);
  final buttonSize = 50;

  @override
  void initState() {
    super.initState();
    // Initialize position to the bottom left corner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      position = Offset(8, screenSize.height - buttonSize - 70);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: IconButton(
              tooltip: 'Give Feedback',
              icon: const Icon(Icons.feedback),
              onPressed: null, // Disable interaction while dragging
              color: Colors.transparent,
            ),
            childWhenDragging: Container(), // Placeholder while dragging
            onDragEnd: (details) {
              // Update the position based on the drag details
              setState(() {
                position = Offset(
                  details.offset.dx, // Center the button
                  details.offset.dy, // Center the button
                );

                // Ensure the button stays within the screen bounds
                position = Offset(
                  position.dx.clamp(0, screenSize.width - buttonSize),
                  position.dy.clamp(0, screenSize.height - buttonSize),
                );
              });
            },
            child: IconButton(
              icon: const Icon(Icons.feedback),
              color: Theme.of(context).colorScheme.primary,
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
        ),
      ],
    );
  }
}
