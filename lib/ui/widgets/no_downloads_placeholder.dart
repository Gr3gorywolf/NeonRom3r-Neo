import 'package:flutter/material.dart';
import 'package:test_app/utils/animations_helper.dart';

class NoDownloadsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new AnimationHelper().fadeInOutAnimation(
      child: Center(
        heightFactor: 2,
        child: Column(
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
