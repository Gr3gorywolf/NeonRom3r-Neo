import 'dart:async';

import 'package:android_intent/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/emulator.dart';

class EmulatorListItem extends StatefulWidget {
  Emulator emulator;
  EmulatorListItem(this.emulator);

  @override
  _EmulatorListItemState createState() => _EmulatorListItemState();
}

class _EmulatorListItemState extends State<EmulatorListItem> {
  bool isFetchingAvailability = false;
  bool isEmulatorAvailable = false;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    checkAvailability();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      checkAvailability();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  checkAvailability() async {
    var result = await DeviceApps.isAppInstalled(widget.emulator.packageName!);
    setState(() {
      isEmulatorAvailable = result;
    });
  }

  String get emulatorTag {
    var compatibility =
        widget.emulator.isCompatible! ? "Compatible" : "Incompatible";
    var availability = isEmulatorAvailable ? "Installed" : "Not installed";
    return "$compatibility - $availability";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (!isEmulatorAvailable) {
          AndroidIntent(
                  data: widget.emulator.downloadLink, action: "action_view")
              .launch();
        } else {
          DeviceApps.openApp(widget.emulator.packageName!);
        }
      },
      contentPadding: EdgeInsets.all(5),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          widget.emulator.image!,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        widget.emulator.name!,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 2,
          ),
          Text(
            isFetchingAvailability ? "Checking availability..." : emulatorTag,
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
