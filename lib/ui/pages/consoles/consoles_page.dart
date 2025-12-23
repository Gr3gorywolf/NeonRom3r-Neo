import 'package:flutter/material.dart';
import 'package:yamata_launcher/ui/widgets/console_list.dart';
import 'package:yamata_launcher/services/console_service.dart';

class ConsolesPage extends StatefulWidget {
  @override
  _ConsolesPageState createState() => _ConsolesPageState();
}

class _ConsolesPageState extends State<ConsolesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Consoles")),
        body: ConsoleList(
          onConsoleSelected: (_) => {},
        ));
  }
}
