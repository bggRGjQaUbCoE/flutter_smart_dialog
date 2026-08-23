import 'dart:async';

import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/show_param.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_widget.dart';
import 'package:material_ui/material_ui.dart';

import '../config/enum_config.dart';
import '../widget/helper/smart_overlay_entry.dart';

///main function : customize dialog
class MainDialog {
  MainDialog({required this.overlayEntry}) : _widget = Container();

  ///OverlayEntry instance
  final SmartOverlayEntry overlayEntry;
  final _uniqueKey = UniqueKey();

  bool visible = true;
  BaseController? _controller;
  final Set<Completer<dynamic>> _dismissCompleters = {};
  VoidCallback? _onDismiss;
  Widget _widget;
  bool _hasShown = false;

  Future<T?> show<T>({required SmartMainDialogParam param}) {
    //custom dialog
    _widget = SmartDialogWidget(
      key: param.reuse ? _uniqueKey : UniqueKey(),
      controller: _controller = SmartDialogWidgetController(),
      alignment: param.alignment,
      usePenetrate: param.usePenetrate,
      useAnimation: param.useAnimation,
      animationTime: param.animationTime,
      animationType: param.animationType,
      nonAnimationTypes: processNonAnimationTypes(
        nonAnimationTypes: param.nonAnimationTypes,
        keepSingle: param.keepSingle,
      ),
      animationBuilder: param.animationBuilder,
      maskColor: param.maskColor,
      maskWidget: param.maskWidget,
      onMask: param.onMask ?? () {},
      maskTriggerType: param.maskTriggerType,
      ignoreArea: param.ignoreArea,
      child: param.widget,
    );

    final completer = Completer<T?>();
    _handleCommonOperate<T>(
      animationTime: param.animationTime,
      onDismiss: param.onDismiss,
      useSystem: param.useSystem,
      awaitOverType: param.awaitOverType,
      completer: completer,
    );

    //wait dialog dismiss
    return completer.future;
  }

  Future<T?> showAttach<T>({required SmartMainAttachParam param}) {
    //attach dialog
    _widget = AttachDialogWidget(
      key: _uniqueKey,
      targetContext: param.targetContext,
      targetBuilder: param.targetBuilder,
      replaceBuilder: param.replaceBuilder,
      adjustBuilder: param.adjustBuilder,
      controller: _controller = AttachDialogController(),
      alignment: param.alignment,
      usePenetrate: param.usePenetrate,
      useAnimation: param.useAnimation,
      animationTime: param.animationTime,
      animationType: param.animationType,
      nonAnimationTypes: processNonAnimationTypes(
        nonAnimationTypes: param.nonAnimationTypes,
        keepSingle: param.keepSingle,
      ),
      animationBuilder: param.animationBuilder,
      scalePointBuilder: param.scalePointBuilder,
      maskColor: param.maskColor,
      maskWidget: param.maskWidget,
      maskTriggerType: param.maskTriggerType,
      onMask: param.onMask ?? () {},
      maskIgnoreArea: param.maskIgnoreArea,
      highlightBuilder: param.highlightBuilder,
      child: param.widget,
    );

    final completer = Completer<T?>();
    _handleCommonOperate<T>(
      animationTime: param.animationTime,
      onDismiss: param.onDismiss,
      useSystem: param.useSystem,
      awaitOverType: param.awaitOverType,
      completer: completer,
    );

    //wait dialog dismiss
    return completer.future;
  }

  List<SmartNonAnimationType> processNonAnimationTypes({
    required List<SmartNonAnimationType> nonAnimationTypes,
    required bool keepSingle,
  }) {
    List<SmartNonAnimationType> nonAnimations = [...nonAnimationTypes];
    var continueKeepSingle = SmartNonAnimationType.continueKeepSingle;
    if (nonAnimations.contains(continueKeepSingle) && keepSingle && _hasShown) {
      nonAnimations.add(SmartNonAnimationType.openDialog_nonAnimation);
    }

    return nonAnimations;
  }

  void _handleCommonOperate<T>({
    required Duration animationTime,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required SmartAwaitOverType awaitOverType,
    required Completer<T?> completer,
  }) {
    _hasShown = true;
    switch (awaitOverType) {
      case SmartAwaitOverType.none:
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 10), () {
            _complete(completer);
          }),
        );
      case SmartAwaitOverType.dialogAppear:
        unawaited(
          Future<void>.delayed(animationTime, () {
            _complete(completer);
          }),
        );
      case SmartAwaitOverType.dialogDismiss:
        _dismissCompleters.add(completer);
    }

    _onDismiss = onDismiss;

    if (useSystem && DialogProxy.contextNavigator != null) {
      var tempWidget = _widget;
      _widget = Container();
      ViewUtils.addSafeUse(() {
        unawaited(
          showDialog<void>(
            context: DialogProxy.contextNavigator!,
            barrierColor: Colors.transparent,
            barrierDismissible: false,
            useSafeArea: false,
            routeSettings: const RouteSettings(name: SmartTag.systemDialog),
            builder: (BuildContext context) => tempWidget,
          ),
        );
      });
    }

    //refresh dialog
    overlayEntry.markNeedsBuild();
  }

  void _complete<T>(Completer<T?> completer, [T? result]) {
    if (!completer.isCompleted) completer.complete(result);
  }

  Future<void> dismiss<T>({
    bool useSystem = false,
    T? result,
    CloseType closeType = CloseType.normal,
  }) async {
    //dialog prepare dismiss
    _onDismiss?.call();

    //close animation
    await _controller?.dismiss(closeType: closeType);

    //remove dialog
    _widget = Container();
    overlayEntry.markNeedsBuild();

    if (useSystem && DialogProxy.contextNavigator != null) {
      Navigator.pop(DialogProxy.contextNavigator!);
    }

    // safety await
    await ViewUtils.awaitPostFrame();

    //end waiting
    final completers = _dismissCompleters.toList(growable: false);
    _dismissCompleters.clear();
    for (final completer in completers) {
      _complete<dynamic>(completer, result);
    }
  }

  void resetForTest() {
    for (final completer in _dismissCompleters) {
      _complete<dynamic>(completer);
    }
    _dismissCompleters.clear();
    _controller = null;
    _onDismiss = null;
    _widget = Container();
    _hasShown = false;
    visible = true;
  }

  Widget getWidget() => Offstage(offstage: !visible, child: _widget);
}
