import 'package:flutter/material.dart';
import '../../resources/database/sync/sync.dart';

class SettingsSyncLog extends StatefulWidget {
  const SettingsSyncLog({super.key});

  @override
  State<SettingsSyncLog> createState() => _SettingsSyncLogState();
}

class _SettingsSyncLogState extends State<SettingsSyncLog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchronization Log'),
      ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(Sync().syncLog),
        ));
  }
}
