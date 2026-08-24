// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  testWidgets('standalone Material UI example shows a SmartDialog toast', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('SmartDialog-EasyDemo'), findsOneWidget);
    expect(find.text('showToast'), findsOneWidget);

    await tester.tap(find.text('showToast'));
    await tester.pump();

    expect(find.textContaining('test toast ----'), findsOneWidget);

    final dismissFuture = SmartDialog.dismiss(status: SmartStatus.allToast);
    await tester.pump(SmartDialog.config.toast.animationTime);
    await tester.pump(const Duration(milliseconds: 50));
    await dismissFuture;
    await tester.pump();

    expect(find.textContaining('test toast ----'), findsNothing);
  });
}
