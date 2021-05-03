import 'package:flutter/material.dart';

class DownloadSpinner extends StatelessWidget {
  double percent;
  DownloadSpinner(this.percent);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(
          strokeWidth: 2,
          value: percent / 100,
        ),
        SizedBox(
          height: 6,
        ),
        Text(
          "${percent}%",
          style: TextStyle(color: Colors.green, fontSize: 12),
        )
      ],
    );
  }
}
