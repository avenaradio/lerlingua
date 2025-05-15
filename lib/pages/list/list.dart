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
        // List from the List  Mirror().filterEntries.sortByTimeModified.entries which is a list of VocabEntry
          body: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(entries[index].wordA),
                subtitle: Text(entries[index].wordB),
              );
            },
          )
      ),
    );
  }
}
