import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';

class AnimationHelper {
  Widget fadeInOutAnimation({Widget child}) {
    return FadeIn(child: child, duration: Duration(seconds: 3));
  }
}
