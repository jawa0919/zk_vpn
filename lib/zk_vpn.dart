import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ZkVpn {
  static MethodChannel _channel = MethodChannel('zk_vpn');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 检查证书
  static Future<bool> get checkCertificate async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<bool>('checkCertificate');
    } else
      throw UnsupportedError("only use android");
  }

  /// 从证书里读取证书的CN项内容
  static Future<String> get certCN async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<String>('getCertCN');
    } else
      throw UnsupportedError("only use android");
  }

  /// 连接vpn
  static Future<bool> get connectVPN async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod<bool>('connectVPN');
    } else
      throw UnsupportedError("only use android");
  }

  /// 获取单点登录信息
  static Future<String> getSSoInfo(String appId, String type) async {
    if (Platform.isAndroid) {
      Map<String, dynamic> params = {"appId": appId, "type": type};
      return _channel.invokeMethod<String>('getSSoInfo', params);
    } else
      throw UnsupportedError("only use android");
  }

  /// 获取用户编码（工号）
  static Future<String> get title async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<String>('getTitle');
    } else
      throw UnsupportedError("only use android");
  }

  /// 地址是否存在vpn策略
  static Future<int> serviceRun(String url) async {
    if (url.isEmpty) return Future.error("url isEmpty");
    Map<String, dynamic> params = {'url': url};
    if (Platform.isAndroid) {
      return _channel.invokeMethod<int>('serviceRun', params);
    } else
      throw UnsupportedError("only use android");
  }

  /// 获取地址的vpn转发地址
  static Future<String> connectServer(String url) async {
    if (url.isEmpty) return Future.error("url isEmpty");
    Map<String, dynamic> params = {'url': url};
    if (Platform.isAndroid) {
      return await _channel.invokeMethod<String>('connectServer', params);
    } else
      throw UnsupportedError("only use android");
  }
}
