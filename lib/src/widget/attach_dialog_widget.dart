import 'package:flutter_smart_dialog/src/config/enum_config.dart';
import 'package:flutter_smart_dialog/src/data/animation_param.dart';
import 'package:flutter_smart_dialog/src/data/attach_model.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/kit/typedef.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/animation/fade_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/highlight_mask_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/scale_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/size_animation.dart';
import 'package:flutter_smart_dialog/src/widget/helper/attach_widget.dart';
import 'package:flutter_smart_dialog/src/widget/helper/dialog_animation_lifecycle.dart';
import 'package:flutter_smart_dialog/src/widget/helper/dialog_scope.dart';
import 'package:flutter_smart_dialog/src/widget/helper/mask_event.dart';
import 'package:material_ui/material_ui.dart';

class AttachDialogWidget extends StatefulWidget {
  const AttachDialogWidget({
    super.key,
    required this.child,
    required this.targetContext,
    required this.targetBuilder,
    required this.adjustBuilder,
    required this.controller,
    required this.animationTime,
    required this.useAnimation,
    required this.onMask,
    required this.alignment,
    required this.usePenetrate,
    required this.animationType,
    required this.nonAnimationTypes,
    required this.animationBuilder,
    required this.scalePointBuilder,
    required this.maskColor,
    required this.highlightBuilder,
    required this.maskWidget,
    required this.maskTriggerType,
    required this.maskIgnoreArea,
  });

  ///target context
  final BuildContext? targetContext;

  /// 自定义坐标点
  final TargetBuilder? targetBuilder;

  final AdjustBuilder? adjustBuilder;

  /// 是否使用动画
  final bool useAnimation;

  ///动画时间
  final Duration animationTime;

  ///自定义的主体布局
  final Widget child;

  ///widget controller
  final AttachDialogController controller;

  /// 点击背景
  final VoidCallback onMask;

  /// 内容控件方向
  final Alignment alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool usePenetrate;

  /// 是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  /// 仅仅针对中间位置的控件
  final SmartAnimationType animationType;

  /// 无动画类型
  final List<SmartNonAnimationType> nonAnimationTypes;

  /// 自定义动画
  final AnimationBuilder? animationBuilder;

  /// 缩放动画的缩放点
  final ScalePointBuilder? scalePointBuilder;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  /// 溶解遮罩,设置高亮位置
  final HighlightBuilder? highlightBuilder;

  /// 遮罩点击时, 被触发的时机
  final SmartMaskTriggerType maskTriggerType;

  /// dialog占位,忽略区域
  final Rect? maskIgnoreArea;

  @override
  State<AttachDialogWidget> createState() => _AttachDialogWidgetState();
}

class _AttachDialogWidgetState extends State<AttachDialogWidget>
    with TickerProviderStateMixin {
  // animation
  DialogAnimationLifecycle? _animationLifecycle;
  AnimationParam? _animationParam;

  // target info
  Alignment? _scaleAlignment;

  late Widget _child;

  @override
  void initState() {
    _child = widget.child;
    _resetState();

    super.initState();
  }

  void _resetState() {
    final startTime = resolveOpenAnimationDuration(
      animationTime: widget.animationTime,
      useAnimation: widget.useAnimation,
      nonAnimationTypes: widget.nonAnimationTypes,
    );

    if (_animationLifecycle == null) {
      _animationLifecycle = DialogAnimationLifecycle(
        vsync: this,
        duration: startTime,
      );
    } else {
      _animationLifecycle!.restart(startTime);
    }

    ViewUtils.addSafeUse(() {
      _animationParam?.onForward?.call();
    });

    //bind controller
    widget.controller._bind(this);
  }

  @override
  void didUpdateWidget(covariant AttachDialogWidget oldWidget) {
    if (oldWidget.child != _child ||
        oldWidget.targetContext != widget.targetContext ||
        oldWidget.targetBuilder != widget.targetBuilder) {
      _resetState();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AttachWidget(
      targetContext: widget.targetContext,
      targetBuilder: widget.targetBuilder,
      beforeBuilder: beforeBuilder,
      alignment: widget.alignment,
      originChild: _child,
      builder: _buildBodyAnimation,
      belowBuilder: (targetOffset, targetSize) {
        return [
          //暗色背景widget动画
          Padding(
            padding: EdgeInsets.only(
              left: widget.maskIgnoreArea?.left ?? 0.0,
              top: widget.maskIgnoreArea?.top ?? 0.0,
              right: widget.maskIgnoreArea?.right ?? 0.0,
              bottom: widget.maskIgnoreArea?.bottom ?? 0.0,
            ),
            child: MaskEvent(
              maskTriggerType: widget.maskTriggerType,
              onMask: widget.onMask,
              child: HighlightMaskAnimation(
                controller: _animationLifecycle!.maskController,
                maskColor: widget.maskColor,
                maskWidget: widget.maskWidget,
                usePenetrate: widget.usePenetrate,
                targetOffset: targetOffset,
                targetSize: targetSize,
                highlightBuilder: widget.highlightBuilder,
                nonAnimationTypes: widget.nonAnimationTypes,
              ),
            ),
          ),
        ];
      },
    );
  }

  AttachAdjustParam beforeBuilder(
    Offset targetOffset,
    Size targetSize,
    Offset selfOffset,
    Size selfSize,
  ) {
    AttachAdjustParam? adjustParam;

    // 处理调整组件
    if (widget.adjustBuilder != null) {
      adjustParam = widget.adjustBuilder!(
        AttachParam(
          targetOffset: targetOffset,
          targetSize: targetSize,
          selfWidget: widget.child,
          selfOffset: selfOffset,
          selfSize: selfSize,
        ),
      );

      final WidgetBuilder? adjustWidgetBuilder = adjustParam.builder;
      if (adjustWidgetBuilder != null) {
        // 必须要写在DialogScope的builder之外,保证在scalePointBuilder之前触发adjustBuilder
        adjustWidgetBuilder(context);
        // 保证 controller 能刷新 adjustBuilder 返回的组件
        if (widget.child is DialogScope) {
          _child = DialogScope(
            controller: (widget.child as DialogScope).controller,
            builder: adjustWidgetBuilder,
          );
        }
      }
    }

    //缩放动画的缩放点
    if (widget.scalePointBuilder != null) {
      var halfWidth = selfSize.width / 2;
      var halfHeight = selfSize.height / 2;
      var scalePoint = widget.scalePointBuilder!(selfSize);
      var scaleDx = scalePoint.dx;
      var scaleDy = scalePoint.dy;
      var rateX = (scaleDx - halfWidth) / halfWidth;
      var rateY = (scaleDy - halfHeight) / halfHeight;
      _scaleAlignment = Alignment(rateX, rateY);
    }

    return AttachAdjustParam(
      alignment: adjustParam?.alignment ?? widget.alignment,
      builder: (context) => _child,
    );
  }

  Widget _buildBodyAnimation(Widget child, AttachAdjustParam? adjustParam) {
    var alignment = adjustParam?.alignment ?? widget.alignment;
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!.call(
        _animationLifecycle!.bodyController,
        child,
        _animationParam = AnimationParam(
          alignment: alignment,
          animationTime: widget.animationTime,
        ),
      );
    }

    var type = widget.animationType;
    final bodyController = _animationLifecycle!.bodyController;
    Widget fade() => FadeAnimation(controller: bodyController, child: child);
    Widget scale() => ScaleAnimation(
      controller: bodyController,
      alignment: _scaleAlignment ?? Alignment.center,
      child: child,
    );
    Widget size() => SizeAnimation(
      alignment: alignment,
      controller: bodyController,
      child: child,
    );
    return switch (type) {
      SmartAnimationType.fade => fade(),
      SmartAnimationType.scale => scale(),
      SmartAnimationType.centerFade_otherSlide =>
        alignment == Alignment.center ? fade() : size(),
      SmartAnimationType.centerScale_otherSlide =>
        alignment == Alignment.center ? scale() : size(),
    };
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss({CloseType closeType = CloseType.normal}) async {
    final animationLifecycle = _animationLifecycle;
    if (animationLifecycle == null) return;

    final endTime = resolveDismissAnimationDuration(
      animationTime: widget.animationTime,
      useAnimation: widget.useAnimation,
      nonAnimationTypes: widget.nonAnimationTypes,
      controller: widget.controller,
      closeType: closeType,
    );
    await animationLifecycle.dismiss(
      endTime,
      onDismiss: _animationParam?.onDismiss,
    );
  }

  @override
  void dispose() {
    _animationLifecycle?.dispose();
    _animationLifecycle = null;
    super.dispose();
  }
}

class AttachDialogController extends BaseController {
  _AttachDialogWidgetState? _state;

  void _bind(_AttachDialogWidgetState state) {
    _state = state;
  }

  @override
  Future<void> dismiss({CloseType closeType = CloseType.normal}) async {
    await _state?.dismiss(closeType: closeType);
  }
}
