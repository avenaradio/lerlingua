import 'package:flutter/material.dart';
import 'package:lerlingua/resources/database/mirror_utils_extension.dart';

import '../../resources/database/mirror.dart';
import '../../resources/database/vocab_card.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<VocabCard> cards = [];

  @override
  void initState() {
    cards = Mirror().filterCards.sortByTimeModified.invertedOrder.cards;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(cards[index].vocabKey.toString()),
                  ),
                  Expanded( // Use Expanded to allow ListTile to take remaining space
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      title: Text(
                        cards[index].wordA,
                        overflow: TextOverflow.ellipsis, // Handle overflow
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cards[index].wordB,
                            overflow: TextOverflow.ellipsis, // Handle overflow
                          ),
                          Text(
                            'Modified: ${cards[index].timeModified}',
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                          ),
                          Text(
                            cards[index].boxNumber.toString(),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}