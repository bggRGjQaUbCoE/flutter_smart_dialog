import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/animation/fade_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/scale_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/slide_animation.dart';

import '../config/enum_config.dart';
import '../data/animation_param.dart';
import '../helper/dialog_proxy.dart';
import 'animation/mask_animation.dart';
import 'helper/dialog_animation_lifecycle.dart';
import 'helper/mask_event.dart';

class SmartDialogWidget extends StatefulWidget {
  const SmartDialogWidget({
    Key? key,
    required this.child,
    required this.controller,
    required this.onMask,
    required this.alignment,
    required this.usePenetrate,
    required this.animationTime,
    required this.useAnimation,
    required this.animationType,
    required this.nonAnimationTypes,
    required this.animationBuilder,
    required this.maskColor,
    required this.maskWidget,
    required this.maskTriggerType,
    required this.ignoreArea,
  }) : super(key: key);

  /// 内容widget
  final Widget child;

  ///widget controller
  final SmartDialogWidgetController controller;

  /// 点击遮罩
  final VoidCallback onMask;

  /// 内容控件方向
  final Alignment alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool usePenetrate;

  /// 动画时间
  final Duration animationTime;

  /// 是否使用动画
  final bool useAnimation;

  /// 是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  /// 仅仅针对中间位置的控件
  final SmartAnimationType animationType;

  /// 无动画类型
  final List<SmartNonAnimationType> nonAnimationTypes;

  /// 自定义动画
  final AnimationBuilder? animationBuilder;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  /// 遮罩点击时, 被触发的时机
  final SmartMaskTriggerType maskTriggerType;

  /// dialog占位,忽略区域
  final Rect? ignoreArea;

  @override
  State<SmartDialogWidget> createState() => _SmartDialogWidgetState();
}

class _SmartDialogWidgetState extends State<SmartDialogWidget>
    with TickerProviderStateMixin {
  DialogAnimationLifecycle? _animationLifecycle;
  AnimationParam? _animationParam;

  @override
  void initState() {
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
  void didUpdateWidget(covariant SmartDialogWidget oldWidget) {
    if (oldWidget.child != widget.child) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.ignoreArea?.left ?? 0.0,
        top: widget.ignoreArea?.top ?? 0.0,
        right: widget.ignoreArea?.right ?? 0.0,
        bottom: widget.ignoreArea?.bottom ?? 0.0,
      ),
      child: Stack(
        children: [
          //暗色背景widget动画
          MaskEvent(
            maskTriggerType: widget.maskTriggerType,
            onMask: widget.onMask,
            child: MaskAnimation(
              controller: _animationLifecycle!.maskController,
              maskColor: widget.maskColor,
              maskWidget: widget.maskWidget,
              usePenetrate: widget.usePenetrate,
            ),
          ),

          //内容Widget动画
          Container(alignment: widget.alignment, child: _buildBodyAnimation()),
        ],
      ),
    );
  }

  Widget _buildBodyAnimation() {
    var child = widget.child;
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!.call(
        _animationLifecycle!.bodyController,
        child,
        _animationParam = AnimationParam(
          alignment: widget.alignment,
          animationTime: widget.animationTime,
        ),
      );
    }

    var type = widget.animationType;
    final bodyController = _animationLifecycle!.bodyController;
    Widget fade = FadeAnimation(controller: bodyController, child: child);
    Widget scale = ScaleAnimation(controller: bodyController, child: child);
    Widget slide = SlideAnimation(
      controller: bodyController,
      alignment: widget.alignment,
      child: child,
    );
    return switch (type) {
      SmartAnimationType.fade => fade,
      SmartAnimationType.scale => scale,
      SmartAnimationType.centerFade_otherSlide =>
        widget.alignment == Alignment.center ? fade : slide,
      SmartAnimationType.centerScale_otherSlide =>
        widget.alignment == Alignment.center ? scale : slide,
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

class SmartDialogWidgetController extends BaseController {
  _SmartDialogWidgetState? _state;

  void _bind(_SmartDialogWidgetState state) {
    _state = state;
  }

  @override
  Future<void> dismiss({CloseType closeType = CloseType.normal}) async {
    await _state?.dismiss(closeType: closeType);
  }
}
