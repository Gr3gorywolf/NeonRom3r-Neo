import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';

class AnimationHelper {
  Widget fadeInOutAnimation({Widget child}) {
    return FadeIn(child: child, duration: Duration(seconds: 3));
  }

  static handleAnimation(AnimationController controller,
      {bool infinite = true, bool reverseAtComplete = true}) {
    controller.forward();
    if (infinite) {
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (reverseAtComplete) {
            controller.reverse();
          } else {
            controller.forward();
          }
        }
        if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    }
  }
}
