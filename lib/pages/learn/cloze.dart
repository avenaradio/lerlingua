import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lerlingua/resources/mirror_utils_extension.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

import '../../enums/move_direction.dart';
import '../../resources/event_bus.dart';
import '../../resources/mirror.dart';

// If no sentence use word
class Cloze {
  final VocabEntry _card;
  final BuildContext? _context;
  @visibleForTesting
  List<String> parts = [];
  List<Widget> widgets = [];
  List<TextEditingController> _controllersForRestore = [];
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<String> _hiddenTexts = [];
  final TextStyle _commonTextStyle = const TextStyle(fontSize: 15.0);
  bool _showAnswers = false;

  Cloze({required VocabEntry card, BuildContext? context}) : _context = context, _card = card {
    // Split sentenceB in %
    parts = card.sentenceB?.split('%') ?? ['', card.wordB];
    _createWidgets();
  }

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

  void _addTextWidget(String text) {
    widgets.add(Text(text, style: const TextStyle(fontSize: 19)));
  }

  void _addInputWidget(String hiddenText) {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    _hiddenTexts.add(hiddenText);
    _controllers.add(controller);
    _focusNodes.add(focusNode);
    final double textWidth = _calculateTextWidth(hiddenText, _commonTextStyle);
    widgets.add(
      SizedBox(
        height: 20,
        width: textWidth,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          style: _commonTextStyle,
          decoration: InputDecoration(
            hintText: '',
            hintStyle: _commonTextStyle,
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
          ),
          onChanged: (String value) {
            _checkInput(value: value, hiddenText: hiddenText, controller: controller, focusNode: focusNode);
          },
        ),
      ),
    );
  }

  // Function to calculate the width of the text based on a given TextStyle
  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width + Random().nextInt(21) + 15;  // Add random padding to the width
  }

  void _checkInput({required String value, required String hiddenText, required TextEditingController controller, required FocusNode focusNode}) {
    _showCharacterOnSpace(value: value, hiddenText: hiddenText, controller: controller);
    // If the text is correct, move focus to the next field
    _moveFocusIfCorrect(value: value, hiddenText: hiddenText, controller: controller, focusNode: focusNode);
    // Store the current controllers
    if (!_showAnswers) {
      _controllersForRestore = _controllers.map((controller) => TextEditingController(text: controller.text)).toList();
    }
  }

  // Function to show the next correct character if space is pressed
  void _showCharacterOnSpace({required String value, required String hiddenText, required TextEditingController controller}) {
    // If last character is not a space, do nothing
    if (value.endsWith(' ')) {
      if (controller.text != hiddenText) {
        //loop to find the first wrong character
        int i = 0; // i is used to not cut off last space if controller.text.length = i
        for (i = 0; i < hiddenText.length; i++) {
          if (i >= controller.text.length) break;
          if (controller.text[i] != hiddenText[i]) {
            controller.text = hiddenText.substring(0, i + 1);
            break;
          } else if (i == hiddenText.length - 1) {
            controller.text = hiddenText;
          }
        }
        //if last letter is a space cut it off
        if (controller.text[controller.text.length - 1] == ' ' && controller.text.length > i) {
          controller.text = controller.text.substring(0, controller.text.length - 1);
        }
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    }
  }

  // Function to move focus to the next field if the current field is correct
  void _moveFocusIfCorrect({required String value, required String hiddenText, required TextEditingController controller, required FocusNode focusNode}) {
    if (controller.text == hiddenText) {
      if (_focusNodes.indexOf(focusNode) < _focusNodes.length - 1) {
        // mounted check
        if (!(_context?.mounted ?? false)) return;
        FocusScope.of(_context!).requestFocus(
            _focusNodes[_focusNodes.indexOf(focusNode) + 1]);
      }
      // check if all fields are correct
      if (_controllers.every((controller) => controller.text == _hiddenTexts[_controllers.indexOf(controller)])) {
        Mirror().move( entry: _card, direction: Direction.next, addNewUndo: true);
        // fire LearningPage event
        LearningPageNewDataEvent event = LearningPageNewDataEvent();
        eventBus.fire(event);
      }
    }
  }

  toggleShowAnswers() {
    _showAnswers = !_showAnswers;
    if (_showAnswers) {
      // Show the correct answers
      for (int i = 0; i < _controllers.length; i++) {
        _controllers[i].text = _hiddenTexts[i];
      }
    } else {
      // Restore the text fields from _controllersForRestore
      for (int i = 0; i < _controllers.length; i++) {
        if (_controllersForRestore.isEmpty) {
          _controllers[i].text = '';
        } else {
          _controllers[i].text = _controllersForRestore[i].text;
        }
      }
    }
    // fire LearningPage event
    LearningPageSetStateEvent event = LearningPageSetStateEvent();
    eventBus.fire(event);
  }
}
