import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../resources/file_utils/book.dart';
import '../../resources/event_bus.dart';
import '../../resources/settings/settings.dart';
import '../theme/theme_filter.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            eventBus.fire(CurrentBookChangedEvent(false));
          },
        ),
        title: Text('Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Import book',
            onPressed: () async {
              try {
                Book? book = await Book.importBook();
                if (book != null) {
                  Settings().currentBook = book;
                  eventBus.fire(CurrentBookChangedEvent(false));
                }
              } catch (e) {
                if(kDebugMode) print(e);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: Settings().books.length,
        itemBuilder: (context, index) {
          Book book = Settings().books[index];
          return ListTile(
            // Image from Uint8List
            leading: book.cover != null ? SizedBox(width: 40, child: ColorFiltered(
                colorFilter: Settings().isDarkMode ? ThemeFilter.undoDark : ThemeFilter.undoLight,
                child: Image.memory(book.cover!))) : Icon(Icons.book_rounded, size: 40),
            title: Text(book.title),
            subtitle: Text(book.author),
            onTap: () {
              book.lastReadTime = DateTime.now().millisecondsSinceEpoch;
              Settings().currentBook = book;
              eventBus.fire(CurrentBookChangedEvent(false));
            },
            onLongPress: () {
              _showDeleteBookDialog(book);
            },
          );
        },
      ),
    );
  }

  Future<void> _showDeleteBookDialog(Book book) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete book'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[Text('Are you sure you want to delete this book?')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                book.deleteBook();
                eventBus.fire(CurrentBookChangedEvent(true));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
