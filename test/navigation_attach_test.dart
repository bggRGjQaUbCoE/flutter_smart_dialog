import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_harness.dart';

void main() {
  testWidgets('bindPage hides on push and reappears on pop', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSmartDialogApp(
      tester,
      navigatorKey: navigatorKey,
      navigatorObservers: [FlutterSmartDialog.observer],
    );

    SmartDialog.show<void>(
      bindPage: true,
      useAnimation: false,
      builder: (_) => const Text('bound-dialog'),
    ).ignore();
    await tester.pump();
    expect(find.text('bound-dialog'), findsOneWidget);

    navigatorKey.currentState!
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('second-page')),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();
    expect(find.text('bound-dialog'), findsNothing);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('bound-dialog'), findsOneWidget);

    await dismissAndPump<void>(tester);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('popping a bound route removes its dialogs', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSmartDialogApp(
      tester,
      navigatorKey: navigatorKey,
      navigatorObservers: [FlutterSmartDialog.observer],
    );

    navigatorKey.currentState!
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('dialog-owner-page')),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();
    SmartDialog.show<void>(
      tag: 'route-owned-dialog',
      bindPage: true,
      useAnimation: false,
      builder: (_) => const Text('route-owned-dialog'),
    ).ignore();
    await tester.pump();
    expect(find.text('route-owned-dialog'), findsOneWidget);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(SmartDialog.checkExist(tag: 'route-owned-dialog'), isFalse);
    expect(find.text('route-owned-dialog'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('showAttach supports all documented alignments', (tester) async {
    BuildContext? targetContext;
    await pumpSmartDialogApp(
      tester,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              targetContext = context;
              return const SizedBox(width: 40, height: 40);
            },
          ),
        ),
      ),
    );

    const alignments = <Alignment>[
      Alignment.topLeft,
      Alignment.topCenter,
      Alignment.topRight,
      Alignment.centerLeft,
      Alignment.center,
      Alignment.centerRight,
      Alignment.bottomLeft,
      Alignment.bottomCenter,
      Alignment.bottomRight,
    ];

    for (final alignment in alignments) {
      SmartDialog.showAttach<void>(
        targetContext: targetContext,
        alignment: alignment,
        useAnimation: false,
        builder: (_) => Text('attach-${alignment.x}-${alignment.y}'),
      ).ignore();
      await tester.pump();
      expect(find.text('attach-${alignment.x}-${alignment.y}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await dismissAndPump<void>(tester, status: SmartStatus.attach);
    }

    await disposeSmartDialogApp(tester);
  });

  testWidgets('adjustBuilder replaces attached content', (tester) async {
    BuildContext? targetContext;
    var adjustCalls = 0;
    await pumpSmartDialogApp(
      tester,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              targetContext = context;
              return const SizedBox(width: 40, height: 40);
            },
          ),
        ),
      ),
    );

    SmartDialog.showAttach<void>(
      targetContext: targetContext,
      useAnimation: false,
      builder: (_) =>
          const SizedBox(width: 60, height: 30, child: Text('original-attach')),
      adjustBuilder: (param) {
        adjustCalls++;
        return const AttachAdjustParam(
          alignment: Alignment.bottomCenter,
          builder: _buildAdjustedAttach,
        );
      },
    ).ignore();
    await tester.pump();
    await tester.pump();

    expect(adjustCalls, greaterThan(0));
    expect(find.text('adjusted-attach'), findsOneWidget);
    expect(find.text('original-attach'), findsNothing);

    await dismissAndPump<void>(tester, status: SmartStatus.attach);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('showAttach accepts a targetBuilder without targetContext', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showAttach<void>(
      targetContext: null,
      targetBuilder: (_, _) => const Offset(16, 24),
      useAnimation: false,
      builder: (_) => const SizedBox(
        width: 20,
        height: 20,
        child: Text('builder-only-attach'),
      ),
    ).ignore();
    await tester.pump();
    await tester.pump();

    expect(find.text('builder-only-attach'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await dismissAndPump<void>(tester, status: SmartStatus.attach);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('showAttach safely handles a context disposed before showing', (
    tester,
  ) async {
    BuildContext? staleContext;
    StateSetter? updateHome;
    var includeTarget = true;
    await pumpSmartDialogApp(
      tester,
      home: StatefulBuilder(
        builder: (context, setState) {
          updateHome = setState;
          return Scaffold(
            body: includeTarget
                ? Builder(
                    builder: (context) {
                      staleContext = context;
                      return const SizedBox(width: 20, height: 20);
                    },
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );

    updateHome!(() => includeTarget = false);
    await tester.pump();
    expect(staleContext!.mounted, isFalse);

    SmartDialog.showAttach<void>(
      targetContext: staleContext,
      useAnimation: false,
      builder: (_) => const Text('stale-context-attach'),
    ).ignore();
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);

    await dismissAndPump<void>(tester, status: SmartStatus.attach);
    await disposeSmartDialogApp(tester);
  });
}

Widget _buildAdjustedAttach(BuildContext context) {
  return const SizedBox(width: 60, height: 30, child: Text('adjusted-attach'));
}
