import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/enum_config.dart';

class MaskEvent extends StatefulWidget {
  const MaskEvent({
    super.key,
    required this.maskTriggerType,
    required this.onMask,
    required this.child,
  });

  final SmartMaskTriggerType maskTriggerType;

  final VoidCallback onMask;

  final Widget child;

  @override
  State<MaskEvent> createState() => _MaskEventState();
}

class _MaskEventState extends State<MaskEvent> {
  bool _maskTrigger = false;

  @override
  Widget build(BuildContext context) {
    Function()? onPointerDown;
    Function()? onPointerMove;
    Function()? onPointerUp;
    if (widget.maskTriggerType == SmartMaskTriggerType.down) {
      onPointerDown = widget.onMask;
    } else if (widget.maskTriggerType == SmartMaskTriggerType.move) {
      onPointerMove = widget.onMask;
    } else {
      onPointerUp = widget.onMask;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        onPointerDown?.call();
        if (onPointerDown != null) _maskTrigger = true;
      },
      onPointerMove: (event) {
        if (!_maskTrigger) onPointerMove?.call();
        if (onPointerMove != null) _maskTrigger = true;
      },
      onPointerUp: (event) {
        onPointerUp?.call();
        if (onPointerUp == null && !_maskTrigger) widget.onMask.call();
        _maskTrigger = false;
      },
      child: widget.child,
    );
  }
}
