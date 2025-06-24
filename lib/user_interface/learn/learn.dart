import 'package:flutter/material.dart';
import 'package:lerlingua/resources/database/mirror/mirror_undo_extension.dart';
import 'package:lerlingua/resources/database/mirror/mirror_utils_extension.dart';
import 'package:lerlingua/resources/settings/settings.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

import '../../general/move_direction.dart';
import '../../resources/event_bus.dart';
import '../../resources/database/mirror/mirror.dart';
import '../cards/edit_card_page.dart';
import 'cloze.dart';

class Learn extends StatefulWidget {
  const Learn({super.key});

  @override
  State<Learn> createState() => _LearnState();
}

class _LearnState extends State<Learn> {
  late VocabCard _currentCard;
  late Cloze _cloze;

  _getCurrentCard() {
    // Mounted check
    if (mounted) {
      setState(() {
        VocabCard? card;
        try {
          card =
              Mirror().filterCards
                  .filterByBoxNumber(Settings().currentBox)
                  .sortByTimeModified
                  .cards
                  .first;
        } catch (e) {
          card = VocabCard(
            vocabKey: -2,
            languageA: 'Welcome',
            wordA: 'This is the leaning page.',
            languageB: 'Lerlingua',
            wordB: 'Learn languages reading.',
            sentenceB: '',
            boxNumber: 1,
            timeModified: 0,
          );
        }
        _currentCard = card;
        _cloze = Cloze(context: context, card: _currentCard);
      });
      _cloze.focusNodes[0].requestFocus();
    }
  }

  _selectBox(int boxNumber) {
    if (boxNumber <= 0 || boxNumber >= 5) {
      return;
    }
    while (Mirror().filterCards.filterByBoxNumber(boxNumber).cards.isEmpty) {
      boxNumber--;
      if (boxNumber <= 1) {
        boxNumber = 1;
        break;
      }
    }
    Settings().currentBox = boxNumber;
    _getCurrentCard();
  }

  @override
  void initState() {
    _getCurrentCard();
    eventBus.on<LearningPageSetStateEvent>().listen((event) => setState(() {}));
    eventBus.on<LearningPageNewDataEvent>().listen(
      (event) => _getCurrentCard(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // List from the List  Mirror().filterCards.sortByTimeModified.cards which is a list of VocabCard
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Align(
              child: Column(
                children: [
                  // LanguageA
                  _currentCard.vocabKey == -2 ? Container() : Center(
                    child: Text(
                      '${_currentCard.languageA}: ${_currentCard.wordA}',
                      style: Cloze.commonTextStyle),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Container(color: Theme.of(context).primaryColor, height: 1),
                  ),
                  // Cloze
                  _currentCard.vocabKey == -2 ? Text('This box is empty', style: Cloze.commonTextStyle) : Wrap(
                    spacing: 8.0, // Space between items
                    runSpacing: 8.0, // Space between lines
                    children: _cloze.widgets,
                  ),
                  SizedBox(height: 16),
                  // Comment
                  _currentCard.comment.isEmpty ? Container() :
                  Center(
                    child: Text(
                      _currentCard.comment,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  _currentCard.comment.isEmpty ? Container() :
                  SizedBox(height: 16),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        // Red cancel button
                        Expanded(
                          child: GestureDetector(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
                              ),
                              onPressed: () {
                                Mirror().move(
                                  card: _currentCard,
                                  direction: Direction.first,
                                  addNewUndo: true,
                                );
                                _getCurrentCard();
                              },
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                            onTapDown: (_) {_cloze.toggleShowAnswers();},
                            onPanEnd: (_) {_cloze.toggleShowAnswers();},
                          ),
                        ),
                        SizedBox(width: 80),
                        // Green check button
                        Expanded(
                          child: GestureDetector(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
                              ),
                              onPressed: () {
                                Mirror().move(
                                  card: _currentCard,
                                  direction: Direction.next,
                                  addNewUndo: true,
                                );
                                _getCurrentCard();
                              },
                              child: Icon(Icons.check, color: Colors.white)
                            ),
                            onTapDown: (_) {_cloze.toggleShowAnswers();},
                            onPanEnd: (_) {_cloze.toggleShowAnswers();},
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vocabulary box
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(50, 30, 20, 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 400, // For big screens
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 1:
                                return GestureDetector(
                                  onTap: () {
                                    Mirror().addStack(
                                      stackSize: Settings().stackSize,
                                    );
                                    _getCurrentCard();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Icon(Icons.trending_flat_rounded),
                                  ),
                                );
                              case 7:
                                return _currentCard.vocabKey == -2 ? Icon(Icons.more_vert_rounded, color: Colors.grey) : PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert_rounded),
                                  onSelected: (String value) {
                                    switch (value) {
                                      case 'Delete card':
                                        Mirror().deleteCard(card: _currentCard);
                                        _getCurrentCard();
                                        break;
                                      case 'Edit card':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditCardPage(
                                              card: _currentCard,
                                            ),
                                          ),
                                        ).then((value) {
                                          _getCurrentCard();
                                        });
                                        break;
                                      default:
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    double height = 30;
                                    return [
                                      PopupMenuItem<String>(
                                        height: height,
                                        value: 'Delete card',
                                        child: Text('Delete card'),
                                      ),
                                      PopupMenuItem<String>(
                                        height: height,
                                        value: 'Edit card',
                                        child: Text('Edit card'),
                                      ),
                                      /*
                                      PopupMenuItem<String>(
                                        height: height,
                                        value: 'Option 3',
                                        child: Text('Option 3'),
                                      ),
                                      */
                                    ];
                                  },
                                );
                              default:
                                return GestureDetector(
                                  onTap: () {
                                    _selectBox(index == 0 ? 0 : index - 1);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        border: Border.all(
                                          color:
                                              Settings().currentBox ==
                                                      (index == 0 ? 0 : index - 1)
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Colors.transparent,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        Mirror().filterCards
                                            .filterByBoxNumber(
                                              index == 0 ? 0 : index - 1,
                                            )
                                            .cards
                                            .length
                                            .toString(),
                                      ),
                                    ),
                                  ),
                                );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // Undo
                  Row(
                    // flex
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Mirror().undoList.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.undo),
                            onPressed: () async {
                              Mirror().undo();
                              _getCurrentCard();
                            },
                            color: Colors.grey,
                          )
                          : const SizedBox.shrink(),
                      Mirror().undoList.isNotEmpty
                          ? Flexible(
                            child: Text(
                              Mirror().undoList.last.description.replaceAll('\n', ' '),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : Container(),
                    ],
                  ),
                  // Add Stack Button
                  if (Settings().currentBox == 1 && Mirror().filterCards.filterByBoxNumber(0).cards.isNotEmpty && Mirror().filterCards.filterByBoxNumber(1).cards.isEmpty)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                      ),
                      child: const Text('Move new cards to first box'),
                      onPressed: () {
                        Mirror().addStack(stackSize: Settings().stackSize);
                        _getCurrentCard();
                      },
                    ),
                  if (Settings().currentBox == 1 && Mirror().filterCards.filterByBoxNumber(0).cards.isEmpty && Mirror().filterCards.filterByBoxNumber(1).cards.isEmpty)
                    Text('You have no new cards in your inbox.'),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
