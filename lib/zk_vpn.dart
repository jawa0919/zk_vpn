
import 'dart:async';

import 'package:flutter/services.dart';

class ZkVpn {
  static const MethodChannel _channel =
      const MethodChannel('zk_vpn');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
