import 'package:flutter/material.dart';
import 'package:test_app/models/console.dart';
import 'package:test_app/utils/assets_helper.dart';

class ConsoleTile extends StatelessWidget {
  Console console;
  int romsCount;
  ConsoleTile(this.console, {this.romsCount});
  @override
  Widget build(BuildContext context) {
    return Container(
     /* decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(18)),
          border: Border.all(color: Colors.green, width: 1.5)),*/
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AssetsHelper.getIcon(console.slug, size: 40),
              SizedBox(
                height: 5,
              ),
              Text(
                console.name,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (romsCount != null)
                Text(
                  "${romsCount} roms",
                  style: TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
