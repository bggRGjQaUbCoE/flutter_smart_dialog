import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/smart_dialog_test_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> pumpSmartDialogApp(
  WidgetTester tester, {
  Widget? home,
  GlobalKey<NavigatorState>? navigatorKey,
  List<NavigatorObserver> navigatorObservers = const [],
}) async {
  SmartDialogTestState.reset();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      home: home ?? const Scaffold(body: SizedBox.expand()),
      builder: FlutterSmartDialog.init(),
    ),
  );
  await tester.pump();
}

Future<void> dismissAndPump<T>(
  WidgetTester tester, {
  SmartStatus status = SmartStatus.smart,
  String? tag,
  T? result,
  bool force = false,
}) async {
  final dismissFuture = SmartDialog.dismiss<T>(
    status: status,
    tag: tag,
    result: result,
    force: force,
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
  await dismissFuture;
}

Future<void> disposeSmartDialogApp(WidgetTester tester) async {
  // Flush delayed await-completion callbacks and display timers before the
  // binding checks for leaked asynchronous work.
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  SmartDialogTestState.reset();
}
