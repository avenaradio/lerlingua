import 'package:flutter/material.dart';
import 'package:lerlingua/resources/mirror_utils_extension.dart';
import 'package:lerlingua/resources/settings.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

import '../../resources/mirror.dart';

class Learn extends StatefulWidget {
  const Learn({super.key});

  @override
  State<Learn> createState() => _LearnState();
}

class _LearnState extends State<Learn> {
  late VocabEntry _currentEntry;

  _getCurrentEntry() {
    setState(() {
      VocabEntry? entry;
      try {
        entry = Mirror().filterEntries.filterByBoxNumber(Settings().currentBox).sortByTimeModified.entries.first;
      }catch (e) {
        entry = VocabEntry(
          vocabKey: -2,
          languageA: 'Welcome',
          wordA: 'This is the leaning page.',
          languageB: 'Lerlingua',
          wordB: 'Learn languages reading.',
          boxNumber: 1,
          timeLearned: 0,
          timeModified: 0
        );
        }
      _currentEntry = entry;
    });
  }
  _selectBox(int boxNumber) {
    if (boxNumber <= 0 || boxNumber >= 5) {
      return;
    }
    while (Mirror().filterEntries.filterByBoxNumber(boxNumber).entries.isEmpty) {
      boxNumber--;
      if (boxNumber <= 1) {
        boxNumber = 1;
        break;
      }
    }
    Settings().currentBox = boxNumber;
    _getCurrentEntry();
  }

  @override
  void initState() {
    _getCurrentEntry();
    /// TODO change
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // List from the List  Mirror().filterEntries.sortByTimeModified.entries which is a list of VocabEntry
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Align(
              child: Column(
                children: [
                  // LanguageA
                  Center(
                    child: Text('${_currentEntry.languageA}: ${_currentEntry.wordA}',
                      style: const TextStyle(fontSize: 19),
                    ),
                  ),
                  SizedBox(height: 10,),
                  // Cloze
                  Wrap(
                    spacing: 8.0, // Space between items
                    runSpacing: 8.0, // Space between lines
                    children: [
                      Text('${_currentEntry.languageB}: ',
                        style: const TextStyle(fontSize: 19),),
                      //..._clozeWidgets.isEmpty ? [Container()] : _clozeWidgets
                    ],
                  ),
                  SizedBox(height: 30,),
                  /* Undo
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HiveData.undoText != null ? Text(HiveData.undoText!, style: TextStyle(color: Theme.of(context).highlightColor),) : Container(),
                        HiveData.isUndoNotEmpty() ?
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: () async{
                            await HiveData.undoLastStep();
                            eventBus.fire(DataUpdatedEvent());
                          },
                          color: Theme.of(context).highlightColor,
                        ) : const SizedBox.shrink(),
                      ]
                  ),*/
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
                              // Add your onPressed logic here
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center, // Center the icon
                              children: [
                                Icon(Icons.close),
                              ],
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
                              // Add your onPressed logic here
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center, // Center the icon
                              children: [
                                Icon(Icons.check),
                              ],
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 1:
                              return GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,),
                                  child: Icon(Icons.trending_flat_rounded),
                                ),
                              );
                            case 7:
                              return GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,),
                                  child: Icon(Icons.more_vert_rounded),
                                ),
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
                                        color: Settings().currentBox == (index == 0 ? 0 : index - 1)
                                            ? Colors.grey.shade900
                                            : Colors.transparent,
                                        width: 1.0,
                                      )),
                                  child: Text(Mirror().filterEntries.filterByBoxNumber(index == 0 ? 0 : index - 1).entries.length.toString()),
                                ),
                              );
                          }
                        }
                        ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
