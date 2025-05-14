import 'package:flutter/material.dart';

import '../../resources/mirror.dart';

class Learn extends StatefulWidget {
  const Learn({super.key});

  @override
  State<Learn> createState() => _LearnState();
}

class _LearnState extends State<Learn> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // List from the List  Mirror().filterEntries.sortByTimeModified.entries which is a list of VocabEntry
        body: ListView.builder(
          itemCount: Mirror().filterEntries.sortByTimeModified.entries.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(Mirror().filterEntries.sortByTimeModified.entries[index].wordA),
              subtitle: Text(Mirror().filterEntries.sortByTimeModified.entries[index].wordB),
            );
          },
        )
      ),
    );
  }
}
