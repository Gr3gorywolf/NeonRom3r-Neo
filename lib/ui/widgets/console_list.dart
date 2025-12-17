import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/utils/assets_helper.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';

class ConsoleList extends StatefulWidget {
  Function(Console) onConsoleSelected;
  Console? selectedConsole;
  List<Console>? consoles;
  ConsoleList(
      {required this.onConsoleSelected, this.selectedConsole, this.consoles});

  @override
  _ConsoleListState createState() => _ConsoleListState();
}

class _ConsoleListState extends State<ConsoleList> {
  List<Console>? _consoles = ConsolesHelper.getConsoles();
  @override
  void initState() {
    super.initState();
    if (widget.consoles != null) {
      _consoles = widget.consoles;
    }
  }

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
    return Center(
      child: Container(
          height: 50,
          margin: EdgeInsets.fromLTRB(15, 7, 15, 7),
          child: Scrollbar(
            controller: scrollController,
            child: ListView.builder(
                controller: scrollController,
                itemCount: _consoles!.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var _currentConsole = this._consoles![index];
                  return FadeInDown(
                    delay: Duration(milliseconds: 50 * index as int),
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
                                  AssetsHelper.getIcon(_currentConsole.slug!,
                                      size: 20),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    _currentConsole.slug!,
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
