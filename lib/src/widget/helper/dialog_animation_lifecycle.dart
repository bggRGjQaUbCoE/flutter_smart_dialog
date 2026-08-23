import 'package:material_ui/material_ui.dart';

import '../../config/enum_config.dart';
import '../../data/base_controller.dart';
import '../../helper/dialog_proxy.dart';

class DialogAnimationLifecycle {
  DialogAnimationLifecycle({
    required TickerProvider vsync,
    required Duration duration,
  }) : maskController = AnimationController(vsync: vsync, duration: duration),
       bodyController = AnimationController(vsync: vsync, duration: duration) {
    maskController.forward();
    bodyController.forward();
  }

  final AnimationController maskController;
  final AnimationController bodyController;

  void restart(Duration duration) {
    maskController.duration = duration;
    bodyController.duration = duration;
    bodyController.value = 0;
    bodyController.forward();
  }

  Future<void> dismiss(Duration duration, {VoidCallback? onDismiss}) async {
    maskController.duration = duration;
    bodyController.duration = duration;
    maskController.reverse();
    bodyController.reverse();
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
