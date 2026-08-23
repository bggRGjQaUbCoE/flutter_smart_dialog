import 'dart:async';

import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/kit/log.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:material_ui/material_ui.dart';

import 'monitor_pop_route.dart';

class BoostRouteMonitor {
  static BoostRouteMonitor? _instance;

  static BoostRouteMonitor get instance => _instance ??= BoostRouteMonitor._();

  BoostRouteMonitor._();

  int threshold = 1000;

  Route<dynamic>? push(Route<dynamic>? route) {
    ViewUtils.addSafeUse(() {
      _monitorRouteMount(route, 0);
    });
    return route;
  }

  void _monitorRouteMount(Route<dynamic>? route, int count) async {
    try {
      if (count > threshold) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));
      if (route?.isActive == false) {
        _monitorRouteMount(route, ++count);
        return;
      }

      if (route is ModalRoute) {
        route.registerPopEntry(_BoostPopEntry(route));
        DialogProxy.contextNavigator = route.subtreeContext;
      }
    } catch (e) {
      SmartLog.d(e);
      _monitorRouteMount(route, ++count);
    }
  }
}

class _BoostPopEntry extends PopEntry<Object?> {
  _BoostPopEntry(this.route);

  final ModalRoute<dynamic> route;

  @override
  final ValueNotifier<bool> canPopNotifier = ValueNotifier<bool>(false);

  bool _handling = false;

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop || _handling) {
      return;
    }
    unawaited(_handlePop(result));
  }

  Future<void> _handlePop(Object? result) async {
    _handling = true;
    try {
      final intercepted = await MonitorPopRoute.handBackEvent();
      final navigator = route.navigator;
      if (intercepted || !route.isActive || navigator == null) {
        return;
      }

      canPopNotifier.value = true;
      await navigator.maybePop<Object?>(result);
    } finally {
      if (route.isActive) {
        canPopNotifier.value = false;
      }
      _handling = false;
    }
  }
}
