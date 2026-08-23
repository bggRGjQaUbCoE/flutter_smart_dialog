import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/smart_dialog_test_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_harness.dart';

void main() {
  testWidgets('normal toasts display sequentially', (tester) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showToast(
      'normal-first',
      displayType: SmartToastType.normal,
      displayTime: const Duration(milliseconds: 100),
      animationTime: Duration.zero,
      useAnimation: false,
    );
    SmartDialog.showToast(
      'normal-second',
      displayType: SmartToastType.normal,
      displayTime: const Duration(milliseconds: 100),
      animationTime: Duration.zero,
      useAnimation: false,
    );
    await tester.pump();
    expect(find.text('normal-first'), findsOneWidget);
    expect(find.text('normal-second'), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(SmartDialog.config.toast.intervalTime);
    await tester.pump();
    expect(find.text('normal-second'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(SmartDialog.config.toast.intervalTime);
    await tester.pump();
    await disposeSmartDialogApp(tester);
  });

  testWidgets('onlyRefresh keeps refreshing after a mask dismissal', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    void showToast(String message) {
      SmartDialog.showToast(
        message,
        clickMaskDismiss: true,
        usePenetrate: false,
        useAnimation: false,
        displayTime: const Duration(seconds: 1),
        displayType: SmartToastType.onlyRefresh,
      );
    }

    showToast('before-dismiss');
    await tester.pump();
    showToast('before-dismiss-refresh');
    await tester.pump();
    expect(find.text('before-dismiss-refresh'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    showToast('after-dismiss');
    await tester.pump();
    showToast('after-dismiss-refresh');
    await tester.pump();

    expect(find.text('after-dismiss-refresh'), findsOneWidget);
    expect(find.text('after-dismiss'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 250));
    await disposeSmartDialogApp(tester);
  });

  testWidgets('multi toasts can be visible at the same time', (tester) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showToast(
      'multi-first',
      displayType: SmartToastType.multi,
      displayTime: const Duration(milliseconds: 100),
      useAnimation: false,
    );
    SmartDialog.showToast(
      'multi-second',
      displayType: SmartToastType.multi,
      displayTime: const Duration(milliseconds: 150),
      useAnimation: false,
    );
    await tester.pump();

    expect(find.text('multi-first'), findsOneWidget);
    expect(find.text('multi-second'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('multi-first'), findsNothing);
    expect(find.text('multi-second'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('works in a standalone Cupertino UI tree without a bridge', (
    tester,
  ) async {
    SmartDialogTestState.reset();
    await tester.pumpWidget(
      cupertino.CupertinoApp(
        home: const cupertino.CupertinoPageScaffold(child: SizedBox.expand()),
        builder: FlutterSmartDialog.init(),
      ),
    );
    await tester.pump();

    SmartDialog.showToast(
      'standalone-cupertino-ui',
      useAnimation: false,
      displayTime: const Duration(milliseconds: 100),
    );
    await tester.pump();
    expect(find.text('standalone-cupertino-ui'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));
    await disposeSmartDialogApp(tester);
  });
}
