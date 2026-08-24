import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:material_ui/material_ui.dart';

part 'smart_dialog_controller.dart';

abstract class DialogScopeAction {
  void setController(SmartDialogController? controller);

  void setChild(Widget? child);
}

class DialogScopeInfo {
  DialogScopeAction? action;
}

class DialogScope extends StatefulWidget {
  DialogScope({super.key, required this.controller, required this.builder});

  final SmartDialogController? controller;

  final WidgetBuilder builder;

  final DialogScopeInfo info = DialogScopeInfo();

  @override
  State<DialogScope> createState() => _DialogScopeState();
}

class _DialogScopeState extends State<DialogScope>
    implements DialogScopeAction {
  VoidCallback? _callback;
  Widget? _child;

  @override
  void initState() {
    widget.info.action = this;
    setController(widget.controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _child ?? widget.builder(context);
  }

  @override
  void setController(SmartDialogController? controller) {
    controller?._setListener(
      _callback = () {
        ViewUtils.addSafeUse(() {
          if (mounted) {
            setState(() {});
          }
        });
      },
    );
  }

  @override
  void setChild(Widget? child) {
    _child = child;
  }

  @override
  void dispose() {
    if (_callback == widget.controller?._callback) {
      widget.controller?._dismiss();
    }

    super.dispose();
  }
}
