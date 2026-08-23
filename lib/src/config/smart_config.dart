import 'smart_config_attach.dart';
import 'smart_config_custom.dart';
import 'smart_config_loading.dart';
import 'smart_config_notify.dart';
import 'smart_config_toast.dart';

/// Global configuration is unified here
///
/// 全局配置统一在此处处理
class SmartConfig {
  /// show(): custom dialog global config
  ///
  /// show(): custom dialog全局配置项
  SmartConfigCustom custom = SmartConfigCustom();

  /// showAttach(): attach dialog global config
  ///
  /// showAttach(): attach dialog全局配置项
  SmartConfigAttach attach = SmartConfigAttach();

  /// showNotify(): notify dialog global config
  ///
  /// showNotify(): notify dialog全局配置项
  SmartConfigNotify notify = SmartConfigNotify();

  /// showLoading(): loading global config
  ///
  /// showLoading(): loading全局配置项
  SmartConfigLoading loading = SmartConfigLoading();

  /// showToast(): toast global config
  ///
  /// showToast(): toast全局配置项
  SmartConfigToast toast = SmartConfigToast();
}
