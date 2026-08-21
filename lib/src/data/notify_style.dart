import 'package:material_ui/material_ui.dart';

class FlutterSmartNotifyStyle {
  const FlutterSmartNotifyStyle({
    this.successBuilder,
    this.failureBuilder,
    this.warningBuilder,
    this.alertBuilder,
    this.errorBuilder,
  });

  final Widget Function(String msg)? successBuilder;
  final Widget Function(String msg)? failureBuilder;
  final Widget Function(String msg)? warningBuilder;
  final Widget Function(String msg)? alertBuilder;
  final Widget Function(String msg)? errorBuilder;
}
