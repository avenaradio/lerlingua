import 'package:flutter/material.dart';
import '../../resources/settings/settings.dart';
import '../../resources/translation_service.dart';

class TranslationServicesList extends StatefulWidget {
  const TranslationServicesList({super.key});

  @override
  State<TranslationServicesList> createState() => _TranslationServicesListState();
}

class _TranslationServicesListState extends State<TranslationServicesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translation Services'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showEditOrAddTranslationServiceDialog(null);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: Settings().translationServices.length,
        itemBuilder: (context, index) {
          TranslationService translationService = Settings().translationServices[index];
          return ListTile(
            leading: Icon(translationService.icon),
            title: Text('${translationService.languageB} - ${translationService.languageA}'),
            subtitle: Text(Uri.parse(translationService.urlAtoB).authority),
            onTap: () {
              if (translationService.key < 100) return;
              _showEditOrAddTranslationServiceDialog(translationService);
            },
            onLongPress: () {
              _showServiceOptionsDialog(translationService);
            },
          );
        },
      ),
    );
  }

  void _showServiceOptionsDialog(TranslationService translationService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              translationService.key < 100 ? Container() : ListTile(
                title: Text('Delete'),
                onTap: () {
                  Settings().deleteTranslationService(translationService);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                title: Text('Duplicate'),
                onTap: () {
                  TranslationService newService = TranslationService(
                    key: null,
                    icon: translationService.icon,
                    languageA: translationService.languageA,
                    languageB: translationService.languageB,
                    urlAtoB: translationService.urlAtoB,
                    urlBtoA: translationService.urlBtoA,
                    injectJs: translationService.injectJs,
                  );
                  Settings().addOrUpdateTranslationService(newService);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditOrAddTranslationServiceDialog(TranslationService? translationService) {
    final languageAController = TextEditingController(text: translationService?.languageA ?? '');
    final languageBController = TextEditingController(text: translationService?.languageB ?? '');
    final urlAtoBController = TextEditingController(text: translationService?.urlAtoB ?? '');
    final urlBtoAController = TextEditingController(text: translationService?.urlBtoA ?? '');
    final injectJsController = TextEditingController(text: translationService?.injectJs ?? '');
    IconData selectedIcon = translationService?.icon ?? Icons.language_rounded;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Edit Translation Service'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('Icon:'),
                        IconButton(
                          icon: Icon(selectedIcon),
                          onPressed: () async {
                            final newIcon = await _showIconPickerDialog(context, selectedIcon);
                            if (newIcon != null) {
                              setDialogState(() {
                                selectedIcon = newIcon;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    TextField(
                      controller: languageBController,
                      decoration: InputDecoration(
                        labelText: 'Book Language',
                      ),
                    ),
                    TextField(
                      controller: languageAController,
                      decoration: InputDecoration(
                        labelText: 'Native Language',
                      ),
                    ),
                    TextField(
                      controller: urlBtoAController,
                      decoration: InputDecoration(
                        labelText: 'Book to Native Translation URL',
                      ),
                    ),
                    TextField(
                      controller: urlAtoBController,
                      decoration: InputDecoration(
                        labelText: 'Native to Book Translation URL',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: injectJsController,
                        minLines: 6,
                        maxLines: 10,
                        decoration: InputDecoration(
                          labelText: 'Inject JS',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    TranslationService updatedTranslationService = TranslationService(
                      key: translationService?.key,
                      icon: selectedIcon,
                      languageA: languageAController.text,
                      languageB: languageBController.text,
                      urlAtoB: urlAtoBController.text,
                      urlBtoA: urlBtoAController.text,
                      injectJs: injectJsController.text,
                    );
                    Settings().addOrUpdateTranslationService(updatedTranslationService);
                    Navigator.of(context).pop();
                    setState(() {}); // Update the list
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<IconData?> _showIconPickerDialog(BuildContext context, IconData selectedIcon) {
    List<IconData> icons = [
      Icons.language_rounded,
      Icons.translate_rounded,
      Icons.g_translate_rounded,
      Icons.favorite_border_rounded,
      Icons.sync_rounded,
      Icons.web_rounded,
      Icons.public_rounded,
      Icons.font_download_rounded,
      Icons.text_fields_rounded,
      Icons.book_rounded,
      Icons.bookmark_rounded,
      Icons.bookmark_border_rounded,
      Icons.library_books_rounded,
      Icons.library_music_rounded,
      Icons.library_add_check_rounded,
      Icons.format_quote_rounded,
      Icons.format_shapes_rounded,
      Icons.text_format_rounded,
      Icons.chat_rounded,
      Icons.record_voice_over_rounded,
      Icons.school_rounded,
      Icons.desktop_windows_rounded,
      Icons.mobile_friendly_rounded,
      Icons.cloud_rounded,
      Icons.restaurant_rounded,
      Icons.cake_rounded,
      Icons.icecream_rounded,
      Icons.pets_rounded,
      Icons.sports_basketball_rounded,
      Icons.sports_cricket_rounded,
      Icons.music_note_rounded,
      Icons.map_rounded,
      Icons.airplanemode_active_rounded,
      Icons.train_rounded,
      Icons.directions_car_rounded,
      Icons.hotel_rounded,
      Icons.agriculture_rounded,
      Icons.beach_access_rounded,
      Icons.directions_bike_rounded,
    ];
    return showDialog<IconData>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick an Icon'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.count(
            crossAxisCount: 5,
            children: icons.map((icon) {
              return IconButton(
                icon: Icon(icon),
                onPressed: () {
                  Navigator.of(context).pop(icon);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(selectedIcon),
          ),
        ],
      ),
    );
  }
}