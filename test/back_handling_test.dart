import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/pop_monitor/monitor_pop_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_harness.dart';

void main() {
  testWidgets('normal back handling closes the active custom dialog', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    SmartDialog.show<void>(
      useAnimation: false,
      backType: SmartBackType.normal,
      builder: (_) => const Text('back-normal'),
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('back-normal'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('onBack interception leaves the dialog visible', (tester) async {
    await pumpSmartDialogApp(tester);
    var onBackCount = 0;
    SmartDialog.show<void>(
      useAnimation: false,
      backType: SmartBackType.normal,
      onBack: () {
        onBackCount++;
        return true;
      },
      builder: (_) => const Text('back-intercepted'),
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isTrue);
    expect(onBackCount, 1);
    expect(find.text('back-intercepted'), findsOneWidget);

    await dismissAndPump<void>(tester);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('block and ignore preserve their documented behavior', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    SmartDialog.showLoading<void>(
      useAnimation: false,
      backType: SmartBackType.block,
      builder: (_) => const Text('loading-blocked'),
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isTrue);
    expect(find.text('loading-blocked'), findsOneWidget);
    await dismissAndPump<void>(tester, status: SmartStatus.loading);

    SmartDialog.showNotify<void>(
      msg: 'notify-ignored',
      notifyType: NotifyType.success,
      displayTime: null,
      useAnimation: false,
      backType: SmartBackType.ignore,
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isFalse);
    expect(find.text('notify-ignored'), findsOneWidget);
    await dismissAndPump<void>(tester, status: SmartStatus.allNotify);
    await disposeSmartDialogApp(tester);
  });
}
