
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingAnimation extends StatelessWidget {
  final Color color;
  LoadingAnimation({this.color = Colors.green});
  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color,
      size: 25.0,
    );
  }
}