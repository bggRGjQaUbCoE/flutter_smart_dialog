import 'dart:async';

import 'package:flutter_smart_dialog/src/config/enum_config.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:material_ui/material_ui.dart';

class DialogAnimationLifecycle {
  DialogAnimationLifecycle({
    required TickerProvider vsync,
    required Duration duration,
  }) : maskController = AnimationController(vsync: vsync, duration: duration),
       bodyController = AnimationController(vsync: vsync, duration: duration) {
    unawaited(maskController.forward());
    unawaited(bodyController.forward());
  }

  final AnimationController maskController;
  final AnimationController bodyController;

  void restart(Duration duration) {
    maskController.duration = duration;
    bodyController.duration = duration;
    bodyController.value = 0;
    unawaited(bodyController.forward());
  }

  Future<void> dismiss(Duration duration, {VoidCallback? onDismiss}) async {
    maskController.duration = duration;
    bodyController.duration = duration;
    unawaited(maskController.reverse());
    unawaited(bodyController.reverse());
    onDismiss?.call();
    await Future<void>.delayed(duration);
  }

  void dispose() {
    maskController.dispose();
    bodyController.dispose();
  }
}

Duration resolveOpenAnimationDuration({
  required Duration animationTime,
  required bool useAnimation,
  required List<SmartNonAnimationType> nonAnimationTypes,
}) {
  if (!useAnimation ||
      nonAnimationTypes.contains(
        SmartNonAnimationType.openDialog_nonAnimation,
      )) {
    return Duration.zero;
  }
  return animationTime;
}

Duration resolveDismissAnimationDuration({
  required Duration animationTime,
  required bool useAnimation,
  required List<SmartNonAnimationType> nonAnimationTypes,
  required BaseController controller,
  required CloseType closeType,
}) {
  if (!useAnimation) {
    return Duration.zero;
  }
  for (final dismissType in nonAnimationTypes) {
    if (controller.judgeDismissDialogType(closeType, dismissType)) {
      return Duration.zero;
    }
  }
  return animationTime;
}
