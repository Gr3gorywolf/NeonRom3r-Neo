import 'package:flutter/material.dart';
import 'package:test_app/ui/widgets/console_list.dart';
import 'package:test_app/utils/consoles_helper.dart';

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
