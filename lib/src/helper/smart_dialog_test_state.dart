import 'package:flutter_smart_dialog/src/custom/toast/toast_tool.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/monitor_widget_helper.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';
import 'package:flutter_smart_dialog/src/kit/debounce_utils.dart';

/// Deterministic cleanup for tests that exercise process-wide singleton state.
///
/// This helper lives under `src` and is deliberately not exported by the
/// package's public library.
class SmartDialogTestState {
  SmartDialogTestState._();

  static void reset() {
    DialogProxy.instance.resetForTest();
    ToastTool.instance.resetForTest();
    DebounceUtils.instance.resetForTest();
    RouteRecord.instance.resetForTest();
    MonitorWidgetHelper.instance.resetForTest();
  }
}
