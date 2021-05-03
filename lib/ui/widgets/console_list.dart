import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:test_app/models/console.dart';
import 'package:test_app/utils/assets_helper.dart';
import 'package:test_app/utils/consoles_helper.dart';

class ConsoleList extends StatefulWidget {
  final Function(Console) onConsoleSelected;
  Console selectedConsole;
  ConsoleList({@required this.onConsoleSelected, this.selectedConsole});

  @override
  _ConsoleListState createState() => _ConsoleListState();
}

class _ConsoleListState extends State<ConsoleList> {
  var _consoles = ConsolesHelper.getConsoles();
  Color getItemBackgroundColor(Console console) {
    if (widget.selectedConsole != null) {
      if (console.slug == widget.selectedConsole.slug) {
        return Colors.green;
      }
    }
    return Colors.grey[800];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 50,
          margin: EdgeInsets.fromLTRB(15, 7, 15, 7),
          child: Scrollbar(
            child: ListView.builder(
                itemCount: _consoles.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var _currentConsole = this._consoles[index];
                  return FadeInDown(
                    delay: Duration(milliseconds: 50 * index),
                    child: GestureDetector(
                      onTap: () => widget.onConsoleSelected(_currentConsole),
                      child: Container(
                        child: Card(
                            color: this.getItemBackgroundColor(_currentConsole),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50)),
                              margin: EdgeInsets.all(7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  AssetsHelper.getIcon(_currentConsole.slug,
                                      size: 20),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    _currentConsole.slug,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  );
                }),
          )),
    );
  }
}
