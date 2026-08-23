import 'package:material_ui/material_ui.dart';

import '../config/enum_config.dart';
import '../kit/typedef.dart';
import 'animation_param.dart';

abstract class SmartShowParamBase {
  const SmartShowParamBase({
    required this.widget,
    required this.alignment,
    required this.clickMaskDismiss,
    required this.animationType,
    required this.nonAnimationTypes,
    required this.animationBuilder,
    required this.usePenetrate,
    required this.useAnimation,
    required this.animationTime,
    required this.maskColor,
    required this.maskWidget,
    required this.onDismiss,
    required this.onMask,
  });

  final Widget widget;
  final Alignment alignment;
  final bool clickMaskDismiss;
  final SmartAnimationType animationType;
  final List<SmartNonAnimationType> nonAnimationTypes;
  final AnimationBuilder? animationBuilder;
  final bool usePenetrate;
  final bool useAnimation;
  final Duration animationTime;
  final Color maskColor;
  final Widget? maskWidget;
  final VoidCallback? onDismiss;
  final VoidCallback? onMask;
}

class SmartShowCustomParam extends SmartShowParamBase {
  const SmartShowCustomParam({
    required super.widget,
    required super.alignment,
    required super.clickMaskDismiss,
    required super.animationType,
    required super.nonAnimationTypes,
    required super.animationBuilder,
    required super.usePenetrate,
    required super.useAnimation,
    required super.animationTime,
    required super.maskColor,
    required super.maskWidget,
    required super.onDismiss,
    required super.onMask,
    required this.debounce,
    required this.displayTime,
    required this.tag,
    required this.keepSingle,
    required this.permanent,
    required this.useSystem,
    required this.bindPage,
    required this.bindWidget,
    required this.ignoreArea,
    required this.backType,
    required this.onBack,
  });

  final bool debounce;
  final Duration? displayTime;
  final String? tag;
  final bool keepSingle;
  final bool permanent;
  final bool useSystem;
  final bool bindPage;
  final BuildContext? bindWidget;
  final Rect? ignoreArea;
  final SmartBackType? backType;
  final SmartOnBack? onBack;
}

class SmartShowAttachParam extends SmartShowCustomParam {
  const SmartShowAttachParam({
    required super.widget,
    required super.alignment,
    required super.clickMaskDismiss,
    required super.animationType,
    required super.nonAnimationTypes,
    required super.animationBuilder,
    required super.usePenetrate,
    required super.useAnimation,
    required super.animationTime,
    required super.maskColor,
    required super.maskWidget,
    required super.onDismiss,
    required super.onMask,
    required super.debounce,
    required super.displayTime,
    required super.tag,
    required super.keepSingle,
    required super.permanent,
    required super.useSystem,
    required super.bindPage,
    required super.bindWidget,
    required super.ignoreArea,
    required super.backType,
    required super.onBack,
    required this.targetContext,
    required this.targetBuilder,
    required this.replaceBuilder,
    required this.adjustBuilder,
    required this.scalePointBuilder,
    required this.maskIgnoreArea,
    required this.highlightBuilder,
  });

  final BuildContext? targetContext;
  final TargetBuilder? targetBuilder;
  final ReplaceBuilder? replaceBuilder;
  final AdjustBuilder? adjustBuilder;
  final ScalePointBuilder? scalePointBuilder;
  final Rect? maskIgnoreArea;
  final HighlightBuilder? highlightBuilder;
}

class SmartShowNotifyParam extends SmartShowParamBase {
  const SmartShowNotifyParam({
    required super.widget,
    required super.alignment,
    required super.clickMaskDismiss,
    required super.animationType,
    required super.nonAnimationTypes,
    required super.animationBuilder,
    required super.usePenetrate,
    required super.useAnimation,
    required super.animationTime,
    required super.maskColor,
    required super.maskWidget,
    required super.onDismiss,
    required super.onMask,
    required this.debounce,
    required this.displayTime,
    required this.tag,
    required this.keepSingle,
    required this.backType,
    required this.onBack,
  });

  final bool debounce;
  final Duration? displayTime;
  final String? tag;
  final bool keepSingle;
  final SmartBackType backType;
  final SmartOnBack? onBack;
}

class SmartShowLoadingParam extends SmartShowParamBase {
  const SmartShowLoadingParam({
    required super.widget,
    required super.alignment,
    required super.clickMaskDismiss,
    required super.animationType,
    required super.nonAnimationTypes,
    required super.animationBuilder,
    required super.usePenetrate,
    required super.useAnimation,
    required super.animationTime,
    required super.maskColor,
    required super.maskWidget,
    required super.onDismiss,
    required super.onMask,
    required this.displayTime,
    required this.backType,
    required this.onBack,
  });

  final Duration? displayTime;
  final SmartBackType backType;
  final SmartOnBack? onBack;
}

class SmartShowToastParam extends SmartShowParamBase {
  const SmartShowToastParam({
    required super.widget,
    required super.alignment,
    required super.clickMaskDismiss,
    required super.animationType,
    required super.nonAnimationTypes,
    required super.animationBuilder,
    required super.usePenetrate,
    required super.useAnimation,
    required super.animationTime,
    required super.maskColor,
    required super.maskWidget,
    required super.onDismiss,
    required super.onMask,
    required this.displayTime,
    required this.debounce,
    required this.displayType,
    required this.consumeEvent,
  });

  final Duration displayTime;
  final bool debounce;
  final SmartToastType displayType;
  final bool consumeEvent;

  SmartShowToastParam withWidget(Widget widget) {
    return SmartShowToastParam(
      widget: widget,
      alignment: alignment,
      clickMaskDismiss: clickMaskDismiss,
      animationType: animationType,
      nonAnimationTypes: nonAnimationTypes,
      animationBuilder: animationBuilder,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      maskColor: maskColor,
      maskWidget: maskWidget,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      debounce: debounce,
      displayType: displayType,
      consumeEvent: consumeEvent,
    );
  }
}

class SmartMainDialogParam extends SmartShowParamBase {
  const SmartMainDialogParam({
    required super.widget,
    required super.alignment,
    required super.clickMaskDismiss,
    required super.animationType,
    required super.nonAnimationTypes,
    required super.animationBuilder,
    required super.usePenetrate,
    required super.useAnimation,
    required super.animationTime,
    required super.maskColor,
    required super.maskWidget,
    required super.onDismiss,
    required super.onMask,
    required this.useSystem,
    required this.reuse,
    required this.awaitOverType,
    required this.maskTriggerType,
    required this.ignoreArea,
    required this.keepSingle,
  });

  final bool useSystem;
  final bool reuse;
  final SmartAwaitOverType awaitOverType;
  final SmartMaskTriggerType maskTriggerType;
  final Rect? ignoreArea;
  final bool keepSingle;
}

class SmartMainAttachParam extends SmartShowParamBase {
  const SmartMainAttachParam({
    required super.widget,
    required super.alignment,
    required super.clickMaskDismiss,
    required super.animationType,
    required super.nonAnimationTypes,
    required super.animationBuilder,
    required super.usePenetrate,
    required super.useAnimation,
    required super.animationTime,
    required super.maskColor,
    required super.maskWidget,
    required super.onDismiss,
    required super.onMask,
    required this.targetContext,
    required this.targetBuilder,
    required this.replaceBuilder,
    required this.adjustBuilder,
    required this.scalePointBuilder,
    required this.maskIgnoreArea,
    required this.highlightBuilder,
    required this.maskTriggerType,
    required this.useSystem,
    required this.awaitOverType,
    required this.keepSingle,
  });

  final BuildContext? targetContext;
  final TargetBuilder? targetBuilder;
  final ReplaceBuilder? replaceBuilder;
  final AdjustBuilder? adjustBuilder;
  final ScalePointBuilder? scalePointBuilder;
  final Rect? maskIgnoreArea;
  final HighlightBuilder? highlightBuilder;
  final SmartMaskTriggerType maskTriggerType;
  final bool useSystem;
  final SmartAwaitOverType awaitOverType;
  final bool keepSingle;
}
