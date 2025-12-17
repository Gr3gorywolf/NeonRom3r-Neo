import 'package:flutter/material.dart';
import 'package:neonrom3r/utils/animation_helper.dart';

class UnselectedPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new AnimationHelper().fadeInOutAnimation(
      child: Center(
        heightFactor: 2,
        child: Column(
          children: [
            Icon(
              Icons.gamepad,
              color: Colors.green,
              size: 180,
            ),
            Text(
              "No console selected",
              style: TextStyle(fontSize: 30, color: Colors.green),
            ),
            Text(
              "Please select a console from list below",
              style: TextStyle(fontSize: 16, color: Colors.green[900]!),
            )
          ],
        ),
      ),
    );
  }
}
