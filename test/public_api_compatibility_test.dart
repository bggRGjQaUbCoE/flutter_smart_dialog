import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('all exported configuration and model types remain constructible', () {
    final custom = SmartConfigCustom(
      alignment: Alignment.center,
      animationType: SmartAnimationType.fade,
      animationTime: Duration.zero,
      useAnimation: false,
      usePenetrate: false,
      maskColor: Colors.transparent,
      maskWidget: const SizedBox.shrink(),
      clickMaskDismiss: false,
      debounce: false,
      debounceTime: Duration.zero,
      bindPage: false,
      awaitOverType: SmartAwaitOverType.dialogDismiss,
      maskTriggerType: SmartMaskTriggerType.up,
      nonAnimationTypes: const [],
      backType: SmartBackType.normal,
    );
    final attach = SmartConfigAttach(
      alignment: Alignment.center,
      animationType: SmartAnimationType.fade,
      animationTime: Duration.zero,
      useAnimation: false,
      usePenetrate: false,
      maskColor: Colors.transparent,
      clickMaskDismiss: false,
      debounce: false,
      debounceTime: Duration.zero,
      bindPage: false,
      awaitOverType: SmartAwaitOverType.dialogDismiss,
      maskTriggerType: SmartMaskTriggerType.up,
      nonAnimationTypes: const [],
      attachAlignmentType: SmartAttachAlignmentType.inside,
      backType: SmartBackType.normal,
    );
    final loading = SmartConfigLoading(
      alignment: Alignment.center,
      animationType: SmartAnimationType.fade,
      animationTime: Duration.zero,
      useAnimation: false,
      usePenetrate: false,
      maskColor: Colors.transparent,
      maskWidget: const SizedBox.shrink(),
      clickMaskDismiss: false,
      leastLoadingTime: Duration.zero,
      awaitOverType: SmartAwaitOverType.dialogDismiss,
      maskTriggerType: SmartMaskTriggerType.up,
      nonAnimationTypes: const [],
      backType: SmartBackType.normal,
    );
    final notify = SmartConfigNotify(
      alignment: Alignment.center,
      animationType: SmartAnimationType.fade,
      animationTime: Duration.zero,
      useAnimation: false,
      usePenetrate: true,
      maskColor: Colors.transparent,
      maskWidget: const SizedBox.shrink(),
      clickMaskDismiss: false,
      debounce: false,
      debounceTime: Duration.zero,
      displayTime: null,
      awaitOverType: SmartAwaitOverType.dialogDismiss,
      maskTriggerType: SmartMaskTriggerType.up,
      nonAnimationTypes: const [],
      backType: SmartBackType.ignore,
    );
    final toast = SmartConfigToast(
      alignment: Alignment.bottomCenter,
      animationType: SmartAnimationType.fade,
      animationTime: Duration.zero,
      useAnimation: false,
      usePenetrate: true,
      maskColor: Colors.transparent,
      maskWidget: const SizedBox.shrink(),
      clickMaskDismiss: false,
      debounce: false,
      debounceTime: Duration.zero,
      displayType: SmartToastType.normal,
      consumeEvent: false,
      displayTime: Duration.zero,
      intervalTime: Duration.zero,
      awaitOverType: SmartAwaitOverType.dialogDismiss,
      maskTriggerType: SmartMaskTriggerType.up,
      nonAnimationTypes: const [],
    );

    SmartDialog.config
      ..custom = custom
      ..attach = attach
      ..loading = loading
      ..notify = notify
      ..toast = toast;

    final animation =
        AnimationParam(
            alignment: Alignment.center,
            animationTime: Duration.zero,
          )
          ..onForward = () {}
          ..onDismiss = () {};
    const attachParam = AttachParam(
      targetOffset: Offset.zero,
      targetSize: Size.zero,
      selfWidget: SizedBox.shrink(),
      selfOffset: Offset.zero,
      selfSize: Size.zero,
    );
    const adjustParam = AttachAdjustParam(alignment: Alignment.center);
    const notifyStyle = FlutterSmartNotifyStyle();
    final controller = SmartDialogController()..refresh();

    expect(animation.alignment, Alignment.center);
    expect(attachParam.targetOffset, Offset.zero);
    expect(adjustParam.alignment, Alignment.center);
    expect(notifyStyle.successBuilder, isNull);
    expect(controller, isA<SmartDialogController>());
  });

  testWidgets('public initialization entrypoints remain usable', (
    tester,
  ) async {
    final observer = FlutterSmartDialog.observer;
    expect(observer, isA<NavigatorObserver>());
    expect(FlutterSmartDialog.boostMonitor(null), isNull);
    await tester.pump(const Duration(milliseconds: 1));

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        builder: FlutterSmartDialog.init(
          builder: (_, child) => child ?? const SizedBox.shrink(),
          toastBuilder: Text.new,
          loadingBuilder: Text.new,
          notifyStyle: const FlutterSmartNotifyStyle(),
          styleBuilder: (child) => child,
          initType: const {
            SmartInitType.custom,
            SmartInitType.attach,
            SmartInitType.loading,
            SmartInitType.toast,
            SmartInitType.notify,
          },
        ),
        home: const SizedBox.shrink(),
      ),
    );
    await tester.pump();
  });
}

// This function is intentionally compile-only. It protects every supported
// named argument while runtime semantics are covered by focused widget tests.
void compileCurrentPublicCalls(BuildContext context) {
  final controller = SmartDialogController();

  SmartDialog.show<void>(
    builder: (_) => const SizedBox.shrink(),
    controller: controller,
    alignment: Alignment.center,
    clickMaskDismiss: false,
    usePenetrate: false,
    useAnimation: false,
    animationType: SmartAnimationType.fade,
    nonAnimationTypes: const [],
    animationBuilder: (_, child, param) => child,
    animationTime: Duration.zero,
    maskColor: Colors.transparent,
    maskWidget: const SizedBox.shrink(),
    debounce: false,
    onDismiss: () {},
    onMask: () {},
    displayTime: null,
    tag: 'legacy-custom',
    keepSingle: false,
    permanent: false,
    useSystem: false,
    bindPage: false,
    bindWidget: context,
    ignoreArea: Rect.zero,
    backType: SmartBackType.normal,
    onBack: () => false,
  ).ignore();

  SmartDialog.showAttach<void>(
    targetContext: context,
    builder: (_) => const SizedBox.shrink(),
    adjustBuilder: (_) => const AttachAdjustParam(),
    controller: controller,
    targetBuilder: (_, _) => Offset.zero,
    alignment: Alignment.center,
    clickMaskDismiss: false,
    animationType: SmartAnimationType.fade,
    nonAnimationTypes: const [],
    animationBuilder: (_, child, param) => child,
    scalePointBuilder: (_) => Offset.zero,
    usePenetrate: false,
    useAnimation: false,
    animationTime: Duration.zero,
    maskColor: Colors.transparent,
    maskWidget: const SizedBox.shrink(),
    maskIgnoreArea: Rect.zero,
    onMask: () {},
    debounce: false,
    highlightBuilder: (_, _) => const Positioned(child: SizedBox.shrink()),
    onDismiss: () {},
    displayTime: null,
    tag: 'legacy-attach',
    keepSingle: false,
    permanent: false,
    useSystem: false,
    bindPage: false,
    bindWidget: context,
    backType: SmartBackType.normal,
    onBack: () => false,
  ).ignore();

  SmartDialog.showNotify<void>(
    msg: 'legacy-notify',
    notifyType: NotifyType.success,
    builder: (_) => const SizedBox.shrink(),
    controller: controller,
    alignment: Alignment.center,
    clickMaskDismiss: false,
    usePenetrate: true,
    useAnimation: false,
    animationType: SmartAnimationType.fade,
    nonAnimationTypes: const [],
    animationBuilder: (_, child, param) => child,
    animationTime: Duration.zero,
    maskColor: Colors.transparent,
    maskWidget: const SizedBox.shrink(),
    debounce: false,
    onDismiss: () {},
    onMask: () {},
    displayTime: null,
    tag: 'legacy-notify',
    keepSingle: false,
    backType: SmartBackType.ignore,
    onBack: () => false,
  ).ignore();

  SmartDialog.showLoading<void>(
    msg: 'legacy-loading',
    controller: controller,
    alignment: Alignment.center,
    clickMaskDismiss: false,
    animationType: SmartAnimationType.fade,
    nonAnimationTypes: const [],
    animationBuilder: (_, child, param) => child,
    usePenetrate: false,
    useAnimation: false,
    animationTime: Duration.zero,
    maskColor: Colors.transparent,
    maskWidget: const SizedBox.shrink(),
    onDismiss: () {},
    onMask: () {},
    displayTime: null,
    backType: SmartBackType.normal,
    onBack: () => false,
    builder: (_) => const SizedBox.shrink(),
  ).ignore();

  SmartDialog.showToast(
    'legacy-toast',
    controller: controller,
    displayTime: Duration.zero,
    alignment: Alignment.bottomCenter,
    clickMaskDismiss: false,
    animationType: SmartAnimationType.fade,
    nonAnimationTypes: const [],
    animationBuilder: (_, child, param) => child,
    usePenetrate: true,
    useAnimation: false,
    animationTime: Duration.zero,
    maskColor: Colors.transparent,
    maskWidget: const SizedBox.shrink(),
    onDismiss: () {},
    onMask: () {},
    consumeEvent: false,
    debounce: false,
    displayType: SmartToastType.normal,
    builder: (_) => const SizedBox.shrink(),
  ).ignore();

  SmartDialog.dismiss<void>(
    status: SmartStatus.smart,
    tag: 'legacy-custom',
    result: null,
    force: false,
  ).ignore();
  SmartDialog.checkExist(
    tag: 'legacy-custom',
    dialogTypes: const {
      SmartAllDialogType.custom,
      SmartAllDialogType.attach,
      SmartAllDialogType.notify,
      SmartAllDialogType.loading,
      SmartAllDialogType.toast,
    },
  );
}
