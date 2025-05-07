# Lerlingua
Learn languages reading.

Lerlingua will be an app containing three main functions:
1. Reading ebooks
   - Minimalistic ebook reader
   - 1st click translation (webview)
   - 2nd click add vocabulary
2. Learn vocabulary
   - Vocabulary box system
   - Cloze
3. Sync across devices (GitHub)

# Development:
- Developed using the flutter framework
- Testing
- Open source
- No server costs

# Wireframes:
Reading:
![reading wireframe](a_documentation/wireframes/reading.jpg)
Learning:
![learning wireframe](a_documentation/wireframes/learning.jpg)

# Tools:
## Rename App
[https://pub.dev/packages/rename](https://pub.dev/packages/rename)
```shell
flutter pub global activate rename
flutter pub global run rename setAppName --targets android,ios,web,windows,macos,linux --value "Lerlingua"
```
## Launcher Icons
[https://pub.dev/packages/flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
Configuration in pubspec.yaml
```shell
dart run flutter_launcher_icons
```
