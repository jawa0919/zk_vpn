import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zk_vpn/zk_vpn.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await ZkVpn.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;
    _platformVersion = platformVersion;
    setState(() {});
  }

  bool _certificate = false;
  bool _vpnConnect = false;
  final _ipController = TextEditingController(text: "172.16.100.6");
  final _portController = TextEditingController(text: "9096");
  String _vpnRes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plugin example app')),
      body: ListView(children: [
        Center(child: Text('Running on: $_platformVersion\n')),
        ListTile(
          leading: Icon(
              _certificate ? Icons.check_box : Icons.check_box_outline_blank),
          title: ElevatedButton(
            onPressed: () async {
              _certificate = false;
              setState(() {});
              final cancel = ToastUtil.loading(context, "检查证书中");
              await PermissionUtil.storage();
              await Future.delayed(Duration(seconds: 1));
              _certificate = await ZkVpn.checkCertificate;
              cancel.call();
              setState(() {});
            },
            child: Text('检查证书 $_certificate'),
          ),
        ),
        ListTile(
          leading: Icon(_vpnConnect ? Icons.cloud_done : Icons.cloud),
          title: ElevatedButton(
            onPressed: () async {
              _vpnConnect = false;
              setState(() {});
              final cancel = ToastUtil.loading(context, "连接VPN中");
              await Future.delayed(Duration(seconds: 1));
              await PermissionUtil.storage();
              _vpnConnect = await ZkVpn.connectVPN;
              cancel.call();
              setState(() {});
            },
            child: Text('连接VPN $_vpnConnect'),
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  keyboardType: TextInputType.url,
                  style: TextStyle(color: Color(0xFF888888)),
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: "IP地址如:192.169.90.245",
                    hintText: '请输入...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.url,
                  style: TextStyle(color: Color(0xFF888888)),
                  controller: _portController,
                  decoration: InputDecoration(
                    labelText: "端口号如:8080",
                    hintText: '请输入...',
                    hintStyle: TextStyle(color: Color(0xFF888888)),
                    border: OutlineInputBorder(),
                  ),
                ),
              )
            ],
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () async {
              _vpnRes = "";
              setState(() {});
              final cancel = ToastUtil.loading(context, "获取VPN转发策略中");
              final ip = _ipController.text;
              final port = _portController.text;
              await Future.delayed(Duration(seconds: 1));
              if (await ZkVpn.serviceRun("$ip:$port") == 0) {
                _vpnRes = '地址未注册';
              } else {
                _vpnRes = await ZkVpn.connectServer("$ip:$port");
              }
              cancel.call();
              setState(() {});
            },
            child: Text('获取VPN转发策略'),
          ),
        ),
        if (_vpnRes != null)
          ListTile(
            title: Text(
              "VPN转发策略结果：$_vpnRes",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        if (_vpnRes != null)
          ListTile(
            title: ElevatedButton(
              onPressed: () async {
                final dio = Dio(BaseOptions(baseUrl: "http://$_vpnRes"));
                final nettest = await dio.get("/nettest");
                ToastUtil.show(nettest.toString());
                print(nettest);
              },
              child: Text('nettest'),
            ),
          ),
      ]),
    );
  }
}

class PermissionUtil {
  /// 启动时请求权限
  static Future<String> launchPermissionRequest() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.storage,
      if (Platform.isIOS) Permission.photos,
    ].request();
    return statuses.toString();
  }

  static Future<bool> location() async {
    if (await Permission.location.serviceStatus != ServiceStatus.enabled) {
      throw ("位置服务未打开");
    }
    await Permission.location.request();
    if (await Permission.location.isGranted) {
      return true;
    } else if (await Permission.location.isDenied) {
      await Permission.location.request();
      if (await Permission.location.isGranted) {
        return true;
      } else {
        throw ("您取消了位置授权");
      }
    } else if (await Permission.locationWhenInUse.isPermanentlyDenied) {
      throw ("您拒绝了位置授权，请在设置中打开");
    } else {
      throw ("位置授权未知错误");
    }
  }

  static Future<bool> camera() async {
    await Permission.camera.request();
    if (await Permission.camera.isGranted) {
      return true;
    } else if (await Permission.camera.isDenied) {
      await Permission.camera.request();
      if (await Permission.camera.isGranted) {
        return true;
      } else {
        throw ("您取消了相机授权");
      }
    } else if (await Permission.camera.isPermanentlyDenied) {
      throw ("您拒绝了相机授权，请在设置中打开");
    } else {
      throw ("相机授权未知错误");
    }
  }

  static Future<bool> microphone() async {
    await Permission.microphone.request();
    if (await Permission.microphone.isGranted) {
      return true;
    } else if (await Permission.microphone.isDenied) {
      await Permission.microphone.request();
      if (await Permission.microphone.isGranted) {
        return true;
      } else {
        throw ("您取消了麦克风授权");
      }
    } else if (await Permission.microphone.isPermanentlyDenied) {
      throw ("您拒绝了麦克风授权，请在设置中打开");
    } else {
      throw ("麦克风授权未知错误");
    }
  }

  static Future<bool> storage() async {
    await Permission.storage.request();
    if (await Permission.storage.isGranted) {
      return true;
    } else if (await Permission.storage.isDenied) {
      await Permission.storage.request();
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        throw ("您取消了文件存储授权");
      }
    } else if (await Permission.storage.isPermanentlyDenied) {
      throw ("您拒绝了文件存储授权，请在设置中打开");
    } else {
      throw ("文件存储授权未知错误");
    }
  }

  static Future<bool> photos() async {
    await Permission.photos.request();
    if (await Permission.photos.isGranted) {
      return true;
    } else if (await Permission.photos.isDenied) {
      await Permission.photos.request();
      if (await Permission.photos.isGranted) {
        return true;
      } else {
        throw ("您取消了相册授权");
      }
    } else if (await Permission.photos.isPermanentlyDenied) {
      throw ("您拒绝了相册授权，请在设置中打开");
    } else {
      throw ("相册授权未知错误");
    }
  }

  /// 定位适用用
  static Future<bool> locationPermissionRequest() async {
    return await location();
  }

  /// 拍视频适用
  static Future<bool> videoPermissionRequest() async {
    return await camera() &&
        await microphone() &&
        await storage() &&
        await photos();
  }

  /// 拍照片适用
  static Future<bool> cameraPermissionRequest() async {
    return await camera() && await storage() && await photos();
  }

  /// 扫描适用
  static Future<bool> qrCodePermissionRequest() async {
    return await camera();
  }

  /// 上传下载适用
  static Future<bool> filePermissionRequest() async {
    return await storage() && await photos();
  }
}

class ToastUtil {
  static void showMsg(BuildContext context, String msg) {
    BotToast.showText(text: msg);
  }

  static void show(String msg) {
    BotToast.showText(text: msg);
  }

  static void notification(String msg) {
    BotToast.showSimpleNotification(title: msg, subTitle: "yes!");
  }

  static CancelFunc loading(BuildContext context, String message) {
    return BotToast.showCustomLoading(
      duration: null,
      align: Alignment.center,
      toastBuilder: (textCancel) => Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}
