import 'dart:convert';
import 'dart:io';
import 'package:android_package_installer/android_package_installer.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'settings.dart';

class Updater {
  static final String owner = 'avenaradio';
  static final String repo = 'lerlingua';

  /// Downloads the latest APK from GitHub and installs it
  static Future<void> update({bool? forceUpdate}) async {
    String? apkUrl = await checkForUpdate();
    if (apkUrl == null) {
      Settings().updateAvailable = false;
      return;
    } else {
      Settings().updateAvailable = true;
    }
    if (Settings().autoUpdate == false && forceUpdate == false) return;
    if (kDebugMode) {
      print('apkUrl: $apkUrl');
    }
    var appDocDir = await getTemporaryDirectory();
    String savePath = '${appDocDir.path}/lerlingua.apk';
    if (kDebugMode) {
      print('Downloading APK from $apkUrl to $savePath');
    }
    try {
      final response = await http.get(Uri.parse(apkUrl));
      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        AndroidPackageInstaller.installApk(apkFilePath: savePath);
        // Optionally handle the result "res" here
      } else {
        if (kDebugMode) {
          print('Failed to download APK. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while downloading APK: $e');
      }
    }
  }

  /// Checks for an update and returns the URL of the latest APK, returns null if no update is available
  static Future<String?> checkForUpdate() async {
    String packageVersion = (await PackageInfo.fromPlatform()).version;
    String latestVersion = '';
    String apkDownloadUrl = '';
    final url = 'https://api.github.com/repos/$owner/$repo/releases/latest';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        latestVersion = data['tag_name'].replaceAll('v', '');
        for (var asset in data['assets']) {
          if ((asset['name'] as String).contains('.apk')) {
            apkDownloadUrl = asset['browser_download_url'];
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
    if (kDebugMode) {
      print('packageVersion: $packageVersion');
      print('latestVersion: $latestVersion');
      print('apkDownloadUrl: $apkDownloadUrl');
    }
    List<int> packageVersionParts =
        packageVersion.split('.').map(int.parse).toList();
    List<int> latestVersionParts =
        latestVersion.split('.').map(int.parse).toList();
    if (packageVersionParts.length < latestVersionParts.length) {
      return apkDownloadUrl;
    }
    for (int i = 0; i < packageVersionParts.length; i++) {
      if (packageVersionParts[i] < latestVersionParts[i]) {
        return apkDownloadUrl;
      }
    }
    return null;
  }
}
