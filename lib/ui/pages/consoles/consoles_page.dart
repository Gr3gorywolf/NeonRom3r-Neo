import 'package:flutter/material.dart';
import 'package:neonrom3r/ui/widgets/console_list.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';

class ConsolesPage extends StatefulWidget {
  @override
  _ConsolesPageState createState() => _ConsolesPageState();
}

class _ConsolesPageState extends State<ConsolesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Consoles")),
      body: ConsoleList(),
    );
  }
}
