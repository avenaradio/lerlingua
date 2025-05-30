import 'package:flutter/material.dart';
import 'package:lerlingua/resources/database/mirror_undo_extension.dart';
import 'package:lerlingua/resources/database/mirror_utils_extension.dart';
import 'package:lerlingua/resources/settings.dart';
import 'package:lerlingua/resources/database/vocab_card.dart';

import '../../general/move_direction.dart';
import '../../resources/event_bus.dart';
import '../../resources/database/mirror.dart';
import '../list/edit_card_page.dart';
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
                      style: const TextStyle(fontSize: 19),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Cloze
                  _currentCard.vocabKey == -2 ? Text('This box is empty', style: const TextStyle(fontSize: 19)) : Wrap(
                    spacing: 8.0, // Space between items
                    runSpacing: 8.0, // Space between lines
                    children: [
                      Text(
                        '${_currentCard.languageB}: ',
                        style: const TextStyle(fontSize: 19),
                      ),
                      ..._cloze.widgets,
                    ],
                  ),
                  SizedBox(height: 30),
                  // Comment
                  Center(
                    child: Text(
                      _currentCard.comment,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        // Red cancel button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Mirror().move(
                                card: _currentCard,
                                direction: Direction.first,
                                addNewUndo: true,
                              );
                              _getCurrentCard();
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Center the icon
                              children: [Icon(Icons.close)],
                            ),
                          ),
                        ),
                        SizedBox(width: 80),
                        // Green check button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              Mirror().move(
                                card: _currentCard,
                                direction: Direction.next,
                                addNewUndo: true,
                              );
                              _getCurrentCard();
                            },
                            onLongPress: () {
                              _cloze.toggleShowAnswers();
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Center the icon
                              children: [Icon(Icons.check)],
                            ),
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
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade500,
                                    border: Border.all(
                                      color:
                                          Settings().currentBox ==
                                                  (index == 0 ? 0 : index - 1)
                                              ? Colors.grey.shade900
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
                              );
                          }
                        },
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
