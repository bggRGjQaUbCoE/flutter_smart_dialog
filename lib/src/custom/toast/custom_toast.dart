import 'dart:async';

import 'package:flutter_smart_dialog/src/custom/toast/toast_tool.dart';
import 'package:flutter_smart_dialog/src/data/base_dialog.dart';
import 'package:flutter_smart_dialog/src/data/show_param.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/kit/debounce_utils.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:flutter_smart_dialog/src/smart_dialog.dart';
import 'package:flutter_smart_dialog/src/widget/helper/dialog_scope.dart';
import 'package:flutter_smart_dialog/src/widget/helper/smart_overlay_entry.dart';
import 'package:flutter_smart_dialog/src/widget/helper/toast_helper.dart';
import 'package:material_ui/material_ui.dart';

class CustomToast extends BaseDialog {
  CustomToast({required SmartOverlayEntry overlayEntry}) : super(overlayEntry);

  Future<void> showToast({required SmartShowToastParam param}) {
    if (DebounceUtils.instance.banContinue(
      DebounceType.toast,
      param.debounce,
    )) {
      return Future<void>.value();
    }

    late ToastInfo info;
    info = ToastInfo(
      type: param.displayType,
      mainDialog: mainDialog,
      displayTime: param.displayTime,
      onShow: () => _showCurrent(param, info),
      refreshScope: _findDialogScope(param.widget),
      refreshWidget: param.widget,
    );
    return ToastTool.instance.show(info);
  }

  void _showCurrent(SmartShowToastParam param, ToastInfo info) {
    ViewUtils.insertOverlayEntry(DialogProxy.contextToast, overlayEntry);
    unawaited(
      mainDialog.show<void>(
        param: SmartMainDialogParam(
          widget: param.widget,
          alignment: param.alignment,
          clickMaskDismiss: param.clickMaskDismiss,
          animationType: param.animationType,
          nonAnimationTypes: param.nonAnimationTypes,
          animationBuilder: param.animationBuilder,
          usePenetrate: param.usePenetrate,
          useAnimation: param.useAnimation,
          animationTime: param.animationTime,
          maskColor: param.maskColor,
          maskWidget: param.maskWidget,
          onDismiss: param.onDismiss,
          useSystem: false,
          reuse: false,
          awaitOverType: SmartDialog.config.toast.awaitOverType,
          maskTriggerType: SmartDialog.config.toast.maskTriggerType,
          ignoreArea: null,
          keepSingle: false,
          onMask: () {
            param.onMask?.call();
            if (!param.clickMaskDismiss ||
                DebounceUtils.instance.banContinue(DebounceType.mask, true)) {
              return;
            }
            unawaited(ToastTool.instance.dismissInfo(info));
          },
        ),
      ),
    );
  }

  DialogScope? _findDialogScope(Widget widget) {
    if (widget is! ToastHelper || widget.child is! DialogScope) return null;
    return widget.child as DialogScope;
  }

  static Future<T?> dismiss<T>({bool closeAll = false}) async {
    await ToastTool.instance.dismiss(closeAll: closeAll);
    return null;
  }
}
