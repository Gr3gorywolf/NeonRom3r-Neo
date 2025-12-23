import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:neonrom3r/constants/settings_constants.dart';
import 'package:neonrom3r/services/alerts_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';
import 'package:neonrom3r/services/settings_service.dart';
import 'package:neonrom3r/ui/pages/settings/console_sources/console_sources_page.dart';
import 'package:neonrom3r/ui/pages/settings/download_sources/download_sources_page.dart';
import 'package:neonrom3r/ui/pages/settings/emulator_settings/emulator_settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var appVersion = "---";
  var downloadPath = "";
  var prefixConsoleSlug = false;
  var enableImageCaching = false;

  fetchInitialValues() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    downloadPath = FileSystemService.downloadsPath;
    prefixConsoleSlug =
        await SettingsService().get<bool>(SettingsKeys.PREFIX_CONSOLE_SLUG);
    enableImageCaching =
        await SettingsService().get<bool>(SettingsKeys.ENABLE_IMAGE_CACHING);
    appVersion = packageInfo.version;
    setState(() {});
  }

  setSettingValue<T>(SettingsKeys key, T value) async {
    switch (key) {
      case SettingsKeys.DOWNLOAD_PATH:
        downloadPath = value as String;
        break;
      case SettingsKeys.PREFIX_CONSOLE_SLUG:
        prefixConsoleSlug = value as bool;
        break;
      case SettingsKeys.ENABLE_IMAGE_CACHING:
        enableImageCaching = value as bool;
        break;
      default:
        break;
    }
    await SettingsService().set<T>(key, value);
    if (key == SettingsKeys.DOWNLOAD_PATH) {
      await FileSystemService.setupDownloadsPath();
    }
    setState(() {});
  }

  handlePickDownloadsPath() async {
    // Use file picker to select directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      //test if can write and read a file on it
      var testFile = File(selectedDirectory + "/test");
      try {
        await testFile.writeAsString("test");
        await testFile.readAsString();
        await testFile.delete();
        await setSettingValue<String>(
            SettingsKeys.DOWNLOAD_PATH, selectedDirectory);
      } catch (e) {
        AlertsService.showErrorSnackbar(context,
            exception:
                Exception("Cannot write/read in the selected directory"));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInitialValues();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      AlertsService.showErrorSnackbar(context,
          exception: Exception('Could not launch the url'));
    }
  }

  handleDeleteCachePath() async {
    var deleted = await FileSystemService.deleteCachePath();
    if (deleted) {
      AlertsService.showSnackbar(context, "Cache cleared successfully");
    } else {
      AlertsService.showErrorSnackbar(context,
          exception: Exception("Could not clear the cache"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    "Sources",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  leading: Icon(Icons.download_sharp),
                  trailing: Icon(Icons.chevron_right),
                  title: Text("Download Sources"),
                  subtitle: Text("Manage your download sources"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DownloadSourcesPage(),
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.gamepad),
                  trailing: Icon(Icons.chevron_right),
                  title: Text("Console Sources"),
                  subtitle: Text("Manage your console sources"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ConsoleSourcesPage(),
                    ));
                  },
                ),
                SizedBox(
                  height: 18,
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    "Paths",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  leading: Icon(Icons.folder),
                  trailing: Icon(Icons.edit),
                  title: Text("Download path"),
                  subtitle: Opacity(
                      opacity: 0.7,
                      child: Text(FileSystemService.downloadsPath)),
                  onTap: () {
                    handlePickDownloadsPath();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.drive_file_move),
                  trailing: Switch(
                    value: prefixConsoleSlug,
                    onChanged: (value) {
                      setSettingValue<bool>(
                          SettingsKeys.PREFIX_CONSOLE_SLUG, value);
                    },
                  ),
                  title: Text("Add console name folder"),
                  subtitle: Opacity(
                    opacity: 0.7,
                    child: Text(
                        "Put your roms in folders named after consoles e.g. 'nds/{your rom}'"),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ConsoleSourcesPage(),
                    ));
                  },
                ),
                SizedBox(
                  height: 18,
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    "Roms & Emulators",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  leading: Icon(Icons.gamepad),
                  trailing: Icon(Icons.chevron_right),
                  title: Text("Emulator settings"),
                  subtitle: Opacity(
                      opacity: 0.7,
                      child: Text("Manage your emulators for each console")),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EmulatorSettingsPage(),
                    ));
                  },
                ),
                SizedBox(
                  height: 18,
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    "Cache Management",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  trailing: Switch(
                    value: enableImageCaching,
                    onChanged: (value) {
                      setSettingValue<bool>(
                          SettingsKeys.ENABLE_IMAGE_CACHING, value);
                    },
                  ),
                  title: Text("Enable image caching"),
                  subtitle: Opacity(
                      opacity: 0.7,
                      child: Text(
                          "Download the rom portrait when added to the library for a better offline experience")),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ConsoleSourcesPage(),
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Clear app cache"),
                  subtitle: Opacity(
                      opacity: 0.7,
                      child: Text("Delete all cached files to free up space")),
                  onTap: () {
                    handleDeleteCachePath();
                  },
                ),
                SizedBox(
                  height: 18,
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    "About",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  trailing: Icon(Icons.open_in_new),
                  title: Text("Github Repository"),
                  subtitle: Opacity(
                      opacity: 0.7,
                      child: Text("Know more about the project or contribute")),
                  onTap: () {
                    _launchUrl(
                        "https://github.com/Gr3gorywolf/Yamata-launcher");
                  },
                ),
                ListTile(
                  trailing: Icon(Icons.open_in_new),
                  title: Text("App Developed by Gr3gorywolf"),
                  subtitle: Opacity(
                      opacity: 0.7,
                      child: Text("Check out my website for more projects")),
                  onTap: () {
                    _launchUrl("https://gregoryc.dev");
                  },
                ),
                ListTile(
                  title: Opacity(
                      opacity: 0.7, child: Text("App version: ${appVersion}")),
                ),
              ],
            ),
          ),
        ));
  }
}
