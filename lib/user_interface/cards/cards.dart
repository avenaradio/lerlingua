import 'package:flutter/material.dart';
import 'package:lerlingua/resources/database/mirror/mirror_utils_extension.dart';

import '../../resources/database/mirror/mirror.dart';
import '../../resources/database/mirror/vocab_card.dart';
import 'edit_card_page.dart';

enum SelectionAction { delete }
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<VocabCard> cards = [];
  Set<VocabCard> selectedCards = {}; // Track selected item indices

  void _updateCards() {
    cards = Mirror().filterCards.sortByTimeModified.invertedOrder.sortByBoxNumber.cards;
    _selectionModeEnabled = false;
    selectedCards.clear();
    setState(() {});
  }

  bool _selectionModeEnabled = false;
  void _toggleSelection(VocabCard card) {
    if(!_selectionModeEnabled) return;
    setState(() {
      selectedCards.contains(card)
          ? selectedCards.remove(card)
          : selectedCards.add(card);
      if (selectedCards.isEmpty) {
        _selectionModeEnabled = false;
      }
    });
  }

  void _startSelection(VocabCard card) {
    _selectionModeEnabled = true;
    _toggleSelection(card);
  }

  void _performSelectionAction(SelectionAction action) {
    if (_selectionModeEnabled) {
      switch (action) {
        case SelectionAction.delete:
          for (VocabCard card in selectedCards) {
            Mirror().deleteCard(card: card);
          }
          break;
      }
    }
    _updateCards();
  }

  @override
  void initState() {
    _updateCards();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (result, _) {
        _updateCards();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: const Text('Cards'),
            actions: [
              !_selectionModeEnabled ? Container() : IconButton(
                icon: const Icon(Icons.deselect_rounded), 
                tooltip: 'Deselect all',
                onPressed: () {
                  _updateCards();
                },
              ),
              !(_selectionModeEnabled && selectedCards.length == 1) ? Container() : IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit card',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditCardPage(card: selectedCards.first,)),
                  ).then((value) => _updateCards());
                },
              ),
              !_selectionModeEnabled ? Container() : IconButton(
                icon: const Icon(Icons.delete_rounded), 
                tooltip: 'Delete cards',
                onPressed: () {
                  _performSelectionAction(SelectionAction.delete);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add card',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditCardPage()),
                  ).then((value) => _updateCards());
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              VocabCard card = cards[index];
              final isSelected = selectedCards.contains(card);
              return Padding(
                padding: index == cards.length - 1
                    ? const EdgeInsets.fromLTRB(8, 2, 8, 30)
                    : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: GestureDetector(
                  onLongPress: () {
                    _startSelection(card);
                  },
                  onTap: () {
                    if (!_selectionModeEnabled) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditCardPage(card: card,)),
                      ).then((value) => _updateCards());
                    } else {
                      _toggleSelection(card);
                    }
                  },
                  child: Column(
                    children: [
                      (index == 0) ?
                      Align(alignment: Alignment.centerLeft, child: Text('New cards:', style: const TextStyle(fontWeight: FontWeight.bold)))
                      : Container(),
                      (cards[index].boxNumber > cards[(index > 0 ? index - 1 : index)].boxNumber) ?
                      Align(alignment: Alignment.centerLeft, child: Text('Box ${card.boxNumber}:', style: const TextStyle(fontWeight: FontWeight.bold)))
                      : Container(),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        color: isSelected
                            ? Theme.of(context).colorScheme.inversePrimary // Highlight selected item
                            : Theme.of(context).colorScheme.primaryContainer,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  card.wordA,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  card.wordB,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}