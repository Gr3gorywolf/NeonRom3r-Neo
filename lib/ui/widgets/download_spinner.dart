import 'package:flutter/material.dart';

class DownloadSpinner extends StatelessWidget {
  double percent;
  bool showPercent;
  DownloadSpinner(this.percent, {this.showPercent = true});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(
          strokeWidth: 2,
          value: percent / 100,
        ),
        if(showPercent)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 6,
            ),
            Text(
              "${percent}%",
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        )
      ],
    );
  }
}
