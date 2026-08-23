import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/attach_model.dart';

typedef FutureVoidCallback = Future<void> Function();

typedef SmartOnBack = FutureOr<bool> Function();

typedef HighlightBuilder =
    Positioned Function(Offset targetOffset, Size targetSize);

typedef TargetBuilder = Offset Function(Offset targetOffset, Size targetSize);

typedef AdjustBuilder = AttachAdjustParam Function(AttachParam attachParam);

typedef ScalePointBuilder = Offset Function(Size selfSize);
