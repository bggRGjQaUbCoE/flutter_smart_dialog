import 'dart:async';
import 'dart:collection';

import 'package:flutter_smart_dialog/src/config/enum_config.dart';
import 'package:flutter_smart_dialog/src/custom/main_dialog.dart';
import 'package:flutter_smart_dialog/src/smart_dialog.dart';
import 'package:flutter_smart_dialog/src/widget/helper/dialog_scope.dart';
import 'package:material_ui/material_ui.dart';

class ToastTool {
  static ToastTool? _instance;

  static ToastTool get instance => _instance ??= ToastTool._();

  ToastTool._();

  final Queue<ToastInfo> toastQueue = ListQueue<ToastInfo>();
  final List<ToastInfo> _multiToasts = <ToastInfo>[];

  Future<void> show(ToastInfo info) {
    return switch (info.type) {
      SmartToastType.normal => _showNormal(info),
      SmartToastType.last => _showLast(info),
      SmartToastType.onlyRefresh => _showOnlyRefresh(info),
      SmartToastType.multi => _showMulti(info),
    };
  }

  Future<void> dismiss({bool closeAll = false}) async {
    if (closeAll) {
      await _closeAll();
      return;
    }

    final serial = _activeSerial;
    if (serial != null) {
      await _close(serial, dispatchNext: true);
      return;
    }
    if (_multiToasts.isNotEmpty) {
      await _close(_multiToasts.last);
    }
  }

  Future<void> dismissInfo(ToastInfo info) async {
    await _close(info, dispatchNext: info == _activeSerial);
  }

  Future<void> _showNormal(ToastInfo info) {
    toastQueue.addLast(info);
    if (toastQueue.length > 1) {
      return Future<void>.value();
    }
    return _startSerial(info);
  }

  Future<void> _showLast(ToastInfo info) async {
    await _clearSerial();
    toastQueue.addLast(info);
    await _startSerial(info);
  }

  Future<void> _showOnlyRefresh(ToastInfo info) {
    final active = _activeSerial;
    if (active?.type == SmartToastType.onlyRefresh && toastQueue.length == 1) {
      active!
        ..refresh(info.refreshWidget)
        ..displayTime = info.displayTime;
      _scheduleSerialTimer(active);
      return Future<void>.value();
    }

    if (toastQueue.isEmpty) {
      toastQueue.addLast(info);
      unawaited(_startSerial(info));
      return Future<void>.value();
    }

    return _replaceSerialWithOnlyRefresh(info);
  }

  Future<void> _replaceSerialWithOnlyRefresh(ToastInfo info) async {
    await _clearSerial();
    toastQueue.addLast(info);
    unawaited(_startSerial(info));
  }

  Future<void> _showMulti(ToastInfo info) {
    _multiToasts.add(info);
    _show(info);
    info.timer = Timer(info.displayTime, () {
      info.completeDisplay();
      unawaited(_close(info));
    });
    return Future<void>.value();
  }

  Future<void> _startSerial(ToastInfo info) {
    _show(info);
    _scheduleSerialTimer(info);
    return info.displayCompleter.future;
  }

  void _show(ToastInfo info) {
    if (info.closed || info.shown) return;
    info.shown = true;
    info.onShow();
    _syncExist();
  }

  void _scheduleSerialTimer(ToastInfo info) {
    info.timer?.cancel();
    info.timer = Timer(info.displayTime, () {
      info.completeDisplay();
      unawaited(_close(info, dispatchNext: true));
    });
  }

  Future<void> _close(ToastInfo info, {bool dispatchNext = false}) async {
    if (info.closed) return;
    if (info.closing) return info.closeCompleter.future;

    info
      ..closing = true
      ..timer?.cancel()
      ..timer = null
      ..completeDisplay();

    if (info.shown) {
      await info.mainDialog.dismiss<void>();
      info.mainDialog.overlayEntry.remove();
    }

    toastQueue.remove(info);
    _multiToasts.remove(info);
    info
      ..closing = false
      ..closed = true
      ..completeClose();
    _syncExist();

    if (dispatchNext && toastQueue.isNotEmpty) {
      await Future<void>.delayed(SmartDialog.config.toast.intervalTime);
      final next = toastQueue.first;
      if (!next.shown && !next.closed) {
        unawaited(_startSerial(next));
      }
    }
  }

  Future<void> _clearSerial() async {
    if (toastQueue.isEmpty) return;
    final entries = toastQueue.toList(growable: false);
    toastQueue.clear();
    final active = entries.first.shown ? entries.first : null;
    for (final info in entries) {
      if (identical(info, active)) continue;
      _cancelQueued(info);
    }
    if (active != null) {
      await _close(active);
    }
    _syncExist();
  }

  Future<void> _closeAll() async {
    final serial = toastQueue.toList(growable: false);
    toastQueue.clear();
    final activeSerial = serial.isNotEmpty && serial.first.shown
        ? serial.first
        : null;
    for (final info in serial) {
      if (identical(info, activeSerial)) continue;
      _cancelQueued(info);
    }

    final active = <ToastInfo>[?activeSerial, ..._multiToasts];
    await Future.wait<void>(active.map(_close));
    _syncExist();
  }

  void _cancelQueued(ToastInfo info) {
    info
      ..timer?.cancel()
      ..timer = null
      ..completeDisplay()
      ..closed = true
      ..completeClose();
  }

  ToastInfo? get _activeSerial {
    if (toastQueue.isEmpty) return null;
    final first = toastQueue.first;
    return first.shown && !first.closed ? first : null;
  }

  void _syncExist() {
    SmartDialog.config.toast.isExist =
        _activeSerial != null || _multiToasts.any((info) => !info.closed);
  }

  void resetForTest() {
    final entries = <ToastInfo>{...toastQueue, ..._multiToasts};
    toastQueue.clear();
    _multiToasts.clear();
    for (final info in entries) {
      info.timer?.cancel();
      info.mainDialog.resetForTest();
      info.mainDialog.overlayEntry.remove();
      info
        ..completeDisplay()
        ..closed = true
        ..completeClose();
    }
    _syncExist();
  }
}

class ToastInfo {
  ToastInfo({
    required this.type,
    required this.mainDialog,
    required this.displayTime,
    required this.onShow,
    required this.refreshScope,
    required this.refreshWidget,
  });

  final SmartToastType type;
  final MainDialog mainDialog;
  Duration displayTime;
  final void Function() onShow;
  final DialogScope? refreshScope;
  final Widget refreshWidget;

  final Completer<void> displayCompleter = Completer<void>();
  final Completer<void> closeCompleter = Completer<void>();
  Timer? timer;
  SmartDialogController? refreshController;
  bool shown = false;
  bool closing = false;
  bool closed = false;

  void refresh(Widget widget) {
    final scope = refreshScope;
    if (scope == null) return;
    refreshController ??= scope.controller ?? SmartDialogController();
    if (scope.controller == null) {
      scope.info.action?.setController(refreshController);
    }
    scope.info.action?.setChild(widget);
    refreshController?.refresh();
  }

  void completeDisplay() {
    if (!displayCompleter.isCompleted) displayCompleter.complete();
  }

  void completeClose() {
    if (!closeCompleter.isCompleted) closeCompleter.complete();
  }
}
