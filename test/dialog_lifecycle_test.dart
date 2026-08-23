import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_harness.dart';

void main() {
  testWidgets('custom dialog returns a result and calls onDismiss once', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    var dismissCount = 0;

    final resultFuture = SmartDialog.show<int>(
      tag: 'result-dialog',
      useAnimation: false,
      onDismiss: () => dismissCount++,
      builder: (_) => const Text('result-dialog'),
    );
    await tester.pump();

    expect(find.text('result-dialog'), findsOneWidget);
    expect(SmartDialog.checkExist(tag: 'result-dialog'), isTrue);

    await dismissAndPump<int>(tester, tag: 'result-dialog', result: 42);

    expect(await resultFuture, 42);
    expect(dismissCount, 1);
    expect(SmartDialog.checkExist(tag: 'result-dialog'), isFalse);
    expect(find.text('result-dialog'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('tagged and typed dismissals preserve the remaining stack', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.show<void>(
      tag: 'first',
      useAnimation: false,
      builder: (_) => const Text('first-dialog'),
    );
    SmartDialog.show<void>(
      tag: 'second',
      useAnimation: false,
      builder: (_) => const Text('second-dialog'),
    );
    await tester.pump();

    expect(SmartDialog.checkExist(tag: 'first'), isTrue);
    expect(SmartDialog.checkExist(tag: 'second'), isTrue);

    await dismissAndPump<void>(tester, tag: 'first');
    expect(find.text('first-dialog'), findsNothing);
    expect(find.text('second-dialog'), findsOneWidget);

    await dismissAndPump<void>(tester, status: SmartStatus.allCustom);
    expect(find.text('second-dialog'), findsNothing);
    expect(
      SmartDialog.checkExist(dialogTypes: const {SmartAllDialogType.custom}),
      isFalse,
    );
    await disposeSmartDialogApp(tester);
  });

  testWidgets('permanent dialog requires a forced dismissal', (tester) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.show<void>(
      tag: 'permanent',
      permanent: true,
      useAnimation: false,
      builder: (_) => const Text('permanent-dialog'),
    );
    await tester.pump();

    await dismissAndPump<void>(tester, tag: 'permanent');
    expect(find.text('permanent-dialog'), findsOneWidget);

    await dismissAndPump<void>(tester, tag: 'permanent', force: true);
    expect(find.text('permanent-dialog'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('keepSingle refreshes content without stacking overlays', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.show<void>(
      keepSingle: true,
      useAnimation: false,
      builder: (_) => const Text('keep-single-first'),
    );
    await tester.pump();
    SmartDialog.show<void>(
      keepSingle: true,
      useAnimation: false,
      builder: (_) => const Text('keep-single-second'),
    );
    await tester.pump();

    expect(find.text('keep-single-first'), findsNothing);
    expect(find.text('keep-single-second'), findsOneWidget);

    await dismissAndPump<void>(tester, status: SmartStatus.allCustom);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('SmartDialogController refreshes a custom builder', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    final controller = SmartDialogController();
    var value = 0;

    SmartDialog.show<void>(
      controller: controller,
      useAnimation: false,
      builder: (_) => Text('value-$value'),
    );
    await tester.pump();
    expect(find.text('value-0'), findsOneWidget);

    value = 1;
    controller.refresh();
    await tester.pump();
    expect(find.text('value-1'), findsOneWidget);

    await dismissAndPump<void>(tester);
    await disposeSmartDialogApp(tester);
  });
}
