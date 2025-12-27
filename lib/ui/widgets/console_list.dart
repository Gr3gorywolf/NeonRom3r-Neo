import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/services/console_service.dart';

import 'console_card.dart';

class ConsoleList extends StatefulWidget {
  Function(Console) onConsoleSelected;
  Console? selectedConsole;
  List<Console> consoles;
  ConsoleList(
      {required this.onConsoleSelected,
      this.selectedConsole,
      required this.consoles});

  @override
  _ConsoleListState createState() => _ConsoleListState();
}

class _ConsoleListState extends State<ConsoleList> {
  Color? getItemBackgroundColor(Console console) {
    if (widget.selectedConsole != null) {
      if (console.slug == widget.selectedConsole!.slug) {
        return Colors.green;
      }
    }
    return Colors.grey[800];
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    var axisCount = max(2, (MediaQuery.of(context).size.width / 220).floor());
    return GridView.count(
      crossAxisCount: axisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: List.generate(widget.consoles!.length, (index) {
        var _console = widget.consoles![index];
        return ConsoleCard(
          _console,
          onTap: () {
            widget.onConsoleSelected(_console);
          },
        );
      }),
    );
  }
}
