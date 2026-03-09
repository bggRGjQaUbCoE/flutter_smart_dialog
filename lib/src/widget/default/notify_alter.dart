import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

class NotifyAlter extends StatelessWidget {
  const NotifyAlter({
    super.key,
    required this.msg,
  });

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ThemeStyle.backgroundColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          Icons.priority_high_outlined,
          size: 22,
          color: ThemeStyle.textColor,
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(msg, style: TextStyle(color: ThemeStyle.textColor)),
        ),
      ]),
    );
  }
}
