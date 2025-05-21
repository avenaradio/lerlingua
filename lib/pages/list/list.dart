import 'package:flutter/material.dart';
import 'package:lerlingua/resources/mirror_utils_extension.dart';

import '../../resources/mirror.dart';
import '../../resources/vocab_entry.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<VocabEntry> entries = [];

  @override
  void initState() {
    entries = Mirror().filterEntries.sortByTimeModified.invertedOrder.entries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(entries[index].vocabKey.toString()),
                  ),
                  Expanded( // Use Expanded to allow ListTile to take remaining space
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      title: Text(
                        entries[index].wordA,
                        overflow: TextOverflow.ellipsis, // Handle overflow
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entries[index].wordB,
                            overflow: TextOverflow.ellipsis, // Handle overflow
                          ),
                          Text(
                            'Modified: ${entries[index].timeModified}',
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                          ),
                          Text(
                            entries[index].boxNumber.toString(),
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