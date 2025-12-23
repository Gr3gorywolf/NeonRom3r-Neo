import 'package:flutter/material.dart';
import 'package:yamata_launcher/utils/animation_helper.dart';

class NoDownloadsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new AnimationHelper().fadeInOutAnimation(
      child: Center(
        heightFactor: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download_sharp,
              color: Colors.green,
              size: 180,
            ),
            Text(
              "No downloads yet",
              style: TextStyle(fontSize: 30, color: Colors.green),
            )
          ],
        ),
      ),
    );
  }
}
