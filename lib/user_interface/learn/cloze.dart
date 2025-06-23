import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lerlingua/resources/database/mirror/mirror_utils_extension.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';
import '../../general/move_direction.dart';
import '../../resources/event_bus.dart';
import '../../resources/database/mirror/mirror.dart';

class Cloze {
  final VocabCard _card;
  final BuildContext? _context;
  @visibleForTesting
  List<String> parts = [];
  List<Widget> widgets = [];
  @visibleForTesting
  List<TextEditingController> controllersForRestore = [];
  @visibleForTesting
  final List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];
  @visibleForTesting
  final List<String> hiddenTexts = [];
  static final TextStyle commonTextStyle = const TextStyle(fontSize: 16.0);
  @visibleForTesting
  bool showAnswers = false;

  Cloze({required VocabCard card, BuildContext? context}) : _context = context, _card = card {
    // Split sentenceB in %%
    parts = card.sentenceB == '' ? ['${card.languageB}: ', card.wordB] : ('${card.languageB}: ${card.sentenceB}').split('%%'); // TODO use SentenceWithSelectedWords for this
    _createWidgets();
  }

  /// Function to create the widgets
  /// - Tested
  void _createWidgets() {
    int counter = 0;
    for (String text in parts) {
      if (counter % 2 == 0) {
        _addTextWidget(text);
      } else {
        _addInputWidget(text);
      }
      counter++;
    }
  }

  /// Function to add a text widget
  void _addTextWidget(String text) {
    List<String> words = text.trim().split(' ');
    for (String word in words) {
      widgets.add(Text('$word ', style: commonTextStyle));
    }

  }

  /// Function to add an input widget
  void _addInputWidget(String hiddenText) {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    hiddenTexts.add(hiddenText);
    controllers.add(controller);
    focusNodes.add(focusNode);
    final double textWidth = _calculateTextWidth(hiddenText, commonTextStyle);
    widgets.add(
      SizedBox(
        height: 20,
        width: textWidth,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          style: commonTextStyle,
          decoration: InputDecoration(
            hintText: '',
            hintStyle: commonTextStyle,
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
          ),
          onChanged: (String value) {
            _checkInput(hiddenText: hiddenText, controller: controller, focusNode: focusNode);
          },
        ),
      ),
    );
  }

  /// Function to calculate the width of the text based on a given TextStyle
  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width + Random().nextInt(21) + 15;  // Add random padding to the width
  }

  /// Function to check if the input is correct and move focus to the next field
  void _checkInput({required String hiddenText, required TextEditingController controller, required FocusNode focusNode}) {
    showCharacterOnSpace(hiddenText: hiddenText, controller: controller);
    // If the text is correct, move focus to the next field
    _moveFocusIfCorrect(hiddenText: hiddenText, controller: controller, focusNode: focusNode);
    // Store the current controllers
    if (!showAnswers) {
      controllersForRestore = controllers.map((controller) => TextEditingController(text: controller.text)).toList();
    }
  }

  /// Function to show the next correct character if space is pressed
  ///  - Tested
  @visibleForTesting
  void showCharacterOnSpace({required String hiddenText, required TextEditingController controller}) {
    // If last character is not a space, do nothing
    if (controller.text.endsWith(' ')) {
      if (controller.text != hiddenText) {
        //loop to find the first wrong character
        int i = 0; // i is used to not cut off last space if controller.text.length = i
        for (i = 0; i < hiddenText.length; i++) {
          if (i >= controller.text.length) break;
          if (controller.text[i] != hiddenText[i]) {
            // Use the (correct + 1) first characters
            controller.text = hiddenText.substring(0, i + 1);
            break;
          } else if (i == hiddenText.length - 1) {
            // If all characters are correct cut off the end
            controller.text = hiddenText;
          }
        }
        // Move the cursor to the end
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    }
  }

  /// Function to move focus to the next field if the current field is correct
  /// - No unit test because it needs a context, but it works
  void _moveFocusIfCorrect({required String hiddenText, required TextEditingController controller, required FocusNode focusNode}) {
    if (controller.text == hiddenText) {
      if (focusNodes.indexOf(focusNode) < focusNodes.length - 1) {
        // Mounted check
        if (!(_context?.mounted ?? false)) return;
        FocusScope.of(_context!).requestFocus(
            focusNodes[focusNodes.indexOf(focusNode) + 1]);
      }
      // Check if all fields are correct
      if (controllers.every((controller) => controller.text == hiddenTexts[controllers.indexOf(controller)])) {
        Mirror().move( card: _card, direction: Direction.next, addNewUndo: true);
        // Fire LearningPage event
        LearningPageNewDataEvent event = LearningPageNewDataEvent();
        eventBus.fire(event);
      }
    }
  }

  /// Function to toggle the display of the correct answers
  ///  - Tested
  void toggleShowAnswers() {
    showAnswers = !showAnswers;
    if (showAnswers) {
      // Show the correct answers
      for (int i = 0; i < controllers.length; i++) {
        controllers[i].text = hiddenTexts[i];
      }
    } else {
      // Restore the text fields from _controllersForRestore
      for (int i = 0; i < controllers.length; i++) {
        if (controllersForRestore.isEmpty) {
          controllers[i].text = '';
        } else {
          controllers[i].text = controllersForRestore[i].text;
        }
      }
    }
    // Fire LearningPage event
    LearningPageSetStateEvent event = LearningPageSetStateEvent();
    eventBus.fire(event);
  }
}
