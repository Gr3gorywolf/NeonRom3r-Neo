import 'package:flutter/material.dart';
import 'package:test_app/ui/components/console_list.dart';
import 'package:test_app/utils/consoles_helper.dart';

class Consoles extends StatefulWidget {
  @override
  _ConsolesState createState() => _ConsolesState();
}

class _ConsolesState extends State<Consoles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Consoles")),
      body: ConsoleList(),
    );
  }
}
