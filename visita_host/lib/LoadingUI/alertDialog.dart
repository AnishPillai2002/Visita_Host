import 'package:flutter/material.dart';
import 'package:visita_host/LoadingUI/loadingAnimation.dart';

// Loading UI - Alert Dialog
Widget alertBox(String text) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 50,
          child: LoadingAnimation(),
        ),
        SizedBox(width: 40.0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Color(0xff000000)),
          ),
        )
      ],
    ),
  );
}
