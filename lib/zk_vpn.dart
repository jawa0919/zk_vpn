import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ZkVpn {
  static const MethodChannel _channel = const MethodChannel('zk_vpn');
  // static const EventChannel _event = const EventChannel('zk_vpn_vent');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 获取地址的vpn转发地址
  static Future connect(String url) async {
    if (!Platform.isAndroid) throw UnsupportedError("only use android");
    if (url.isEmpty) throw ArgumentError("url isEmpty");
    Map<String, dynamic> params = {'url': url};
    return await _channel.invokeMethod('connect', params) ?? "";
  }
}
