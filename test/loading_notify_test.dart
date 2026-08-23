import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_harness.dart';

void main() {
  testWidgets('loading honors leastLoadingTime before dismissing', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    SmartDialog.config.loading = SmartConfigLoading(
      leastLoadingTime: const Duration(milliseconds: 100),
      useAnimation: false,
    );

    final showFuture = SmartDialog.showLoading<int>(
      msg: 'least-loading',
      builder: (_) => const Text('least-loading'),
    );
    await tester.pump();
    expect(find.text('least-loading'), findsOneWidget);

    final dismissFuture = SmartDialog.dismiss<int>(
      status: SmartStatus.loading,
      result: 7,
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('least-loading'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    await tester.pump();
    await dismissFuture;
    expect(find.text('least-loading'), findsNothing);
    expect(await showFuture, isNull);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('notify auto-dismisses and invokes its callback once', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    var dismissCount = 0;

    SmartDialog.showNotify<void>(
      msg: 'notify-message',
      notifyType: NotifyType.success,
      displayTime: const Duration(milliseconds: 100),
      useAnimation: false,
      onDismiss: () => dismissCount++,
    ).ignore();
    await tester.pump();
    expect(find.text('notify-message'), findsOneWidget);
    expect(
      SmartDialog.checkExist(dialogTypes: const {SmartAllDialogType.notify}),
      isTrue,
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump();
    expect(find.text('notify-message'), findsNothing);
    expect(dismissCount, 1);
    expect(
      SmartDialog.checkExist(dialogTypes: const {SmartAllDialogType.notify}),
      isFalse,
    );
    await disposeSmartDialogApp(tester);
  });

  testWidgets('notify tag dismisses only the matching notification', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showNotify<void>(
      msg: 'notify-one',
      notifyType: NotifyType.success,
      tag: 'notify-one',
      displayTime: null,
      useAnimation: false,
    ).ignore();
    SmartDialog.showNotify<void>(
      msg: 'notify-two',
      notifyType: NotifyType.warning,
      tag: 'notify-two',
      displayTime: null,
      useAnimation: false,
    ).ignore();
    await tester.pump();

    await dismissAndPump<void>(
      tester,
      status: SmartStatus.notify,
      tag: 'notify-one',
    );
    expect(find.text('notify-one'), findsNothing);
    expect(find.text('notify-two'), findsOneWidget);

    await dismissAndPump<void>(tester, status: SmartStatus.allNotify);
    await disposeSmartDialogApp(tester);
  });
}
