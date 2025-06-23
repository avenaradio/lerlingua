import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lerlingua/resources/database/mirror/mirror_utils_extension.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';
import '../../resources/database/mirror/mirror.dart';

class EditCardPage extends StatefulWidget {
  const EditCardPage({super.key, this.card});
  final VocabCard? card;

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  late final VocabCard _card;
  bool _addUndo = true;
  late TextEditingController _languageAController;
  late TextEditingController _wordAController;
  late TextEditingController _languageBController;
  late TextEditingController _wordBController;
  late TextEditingController _sentenceBController;
  late TextEditingController _articleBController;
  late TextEditingController _commentController;
  late TextEditingController _boxNumberController;

  InputDecoration _customDecoration(String label, bool errorCondition) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      errorText: errorCondition ? 'Required' : null,
      border: OutlineInputBorder(),
      errorStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary, // Change the error text color
        fontSize: 14.0, // You can also change the font size if needed
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0), // Change the error border color
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0), // Change the focused error border color
      ),
    );
  }

  @override
  void initState() {
    if (widget.card != null) {
      _card = widget.card!.clone();
    } else {
      _card = VocabCard(
        vocabKey: -1,
        languageA: Mirror().filterCards.sortByTimeModified.invertedOrder.cards.firstOrNull?.languageA ?? '',
        wordA: '',
        languageB: Mirror().filterCards.sortByTimeModified.invertedOrder.cards.firstOrNull?.languageB ?? '',
        wordB: '',
        boxNumber: 0,
        timeModified: DateTime.now().millisecondsSinceEpoch,
      );
      _addUndo = false;
    }
    super.initState();
    _languageAController = TextEditingController(text: _card.languageA);
    _wordAController = TextEditingController(text: _card.wordA);
    _languageBController = TextEditingController(text: _card.languageB);
    _wordBController = TextEditingController(text: _card.wordB);
    _sentenceBController = TextEditingController(text: _card.sentenceB);
    _articleBController = TextEditingController(text: _card.articleB);
    _commentController = TextEditingController(text: _card.comment);
    _boxNumberController = TextEditingController(text: _card.boxNumber.toString());
  }

  @override
  void dispose() {
    _languageAController.dispose();
    _wordAController.dispose();
    _languageBController.dispose();
    _wordBController.dispose();
    _sentenceBController.dispose();
    _articleBController.dispose();
    _commentController.dispose();
    _boxNumberController.dispose();
    super.dispose();
  }

  void _saveCard() {
    // Don't save if any of the fields are empty
    if (
      _languageAController.text.isEmpty ||
      _wordAController.text.isEmpty ||
      _languageBController.text.isEmpty ||
      _wordBController.text.isEmpty
    ) {
      return;
    }
    Mirror().writeCard(card: _card, addNewUndo: _addUndo);
    Navigator.pop(context);
  }

  int _wordAMaxLines = 2;
  int _wordBMaxLines = 2;
  int _sentenceBMaxLines = 2;
  int _commentMaxLines = 2;

  int _calculateMaxLines(String text) {
    if (text.isEmpty) return 1;
    // Count \n + 1 as number of lines
    int maxLines = '\n'.allMatches(text).length + 1;
    return maxLines < 2 ? 2 : maxLines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save',
        child: const Icon(Icons.save_rounded),
        onPressed: () => _saveCard(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        key: Key('languageAInput'),
                        controller: _languageAController,
                        decoration: _customDecoration('Native Language', _languageAController.text.isEmpty),
                        onChanged: (value) {
                          _card.languageA = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        key: Key('languageBInput'),
                        controller: _languageBController,
                        decoration: _customDecoration('Foreign Language', _languageBController.text.isEmpty),
                        onChanged: (value) {
                          _card.languageB = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  key: Key('wordAInput'),
                  maxLines: _wordAMaxLines,
                  controller: _wordAController,
                  decoration: _customDecoration('Native Word', _wordAController.text.isEmpty),
                  onChanged: (value) {
                    _card.wordA = value;
                    setState(() {
                      _wordAMaxLines = _calculateMaxLines(value);
                    });
                    },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  key: Key('wordBInput'),
                  maxLines: _wordBMaxLines,
                  controller: _wordBController,
                  decoration: _customDecoration('Foreign Word', _wordBController.text.isEmpty),
                  onChanged: (value) {
                    _card.wordB = value;
                    setState(() {
                      _wordBMaxLines = _calculateMaxLines(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: _sentenceBMaxLines,
                  controller: _sentenceBController,
                  decoration: InputDecoration(
                    labelText: 'Sentence (Wrap words with %% to create cloze)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _card.sentenceB = value;
                    setState(() {
                      _sentenceBMaxLines = _calculateMaxLines(value);
                    });
                  },
                ),
              ),
              /*
              TextField(
                controller: _articleBController,
                decoration: const InputDecoration(labelText: 'Article'),
                onChanged: (value) => card.articleB = value,
              ),
               */
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: _commentMaxLines,
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Comment',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _card.comment = value;
                    setState(() {
                      _commentMaxLines = _calculateMaxLines(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _boxNumberController,
                  decoration: InputDecoration(
                    labelText: 'Box Number (0-5)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow digits only
                  ],
                  onChanged: (value) {
                    int? parsed = int.tryParse(value);
                    if (parsed == null || parsed < 0 || parsed > 5) {
                      _boxNumberController.text = '';
                    } else {
                      _card.boxNumber = parsed;
                    }
                  },
                  // On submitted, if invalid revert
                  onSubmitted: (value) {
                    int? parsed = int.tryParse(value);
                    if (parsed == null || parsed < 0 || parsed > 5) {
                      _boxNumberController.text = _card.boxNumber.toString();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}