import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseController.judgeDismissDialogType', () {
    final controller = _TestController();

    test('matches every close reason with its non-animation option', () {
      expect(
        controller.judgeDismissDialogType(
          CloseType.normal,
          SmartNonAnimationType.closeDialog_nonAnimation,
        ),
        isTrue,
      );
      expect(
        controller.judgeDismissDialogType(
          CloseType.route,
          SmartNonAnimationType.routeClose_nonAnimation,
        ),
        isTrue,
      );
      expect(
        controller.judgeDismissDialogType(
          CloseType.mask,
          SmartNonAnimationType.maskClose_nonAnimation,
        ),
        isTrue,
      );
      expect(
        controller.judgeDismissDialogType(
          CloseType.back,
          SmartNonAnimationType.backClose_nonAnimation,
        ),
        isTrue,
      );
    });

    test('does not confuse back and mask close reasons', () {
      expect(
        controller.judgeDismissDialogType(
          CloseType.back,
          SmartNonAnimationType.maskClose_nonAnimation,
        ),
        isFalse,
      );
      expect(
        controller.judgeDismissDialogType(
          CloseType.mask,
          SmartNonAnimationType.backClose_nonAnimation,
        ),
        isFalse,
      );
    });
  });
}

class _TestController extends BaseController {
  @override
  Future<void> dismiss({CloseType closeType = CloseType.normal}) async {}
}
