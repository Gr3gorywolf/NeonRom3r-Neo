import 'package:flutter/material.dart';
import 'package:neonrom3r/ui/pages/settings/console_sources/console_sources_page.dart';
import 'package:neonrom3r/ui/pages/download_sources/download_sources_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text("Download Sources"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DownloadSourcesPage(),
                ));
              },
            ),
            ListTile(
              title: Text("Console Sources"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ConsoleSourcesPage(),
                ));
              },
            )
          ],
        ));
  }
}
