import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zk_vpn/zk_vpn.dart';
import 'package:http/http.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyApp());
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
      platformVersion =
          await ZkVpn.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  final _ipController = TextEditingController(text: "10.163.2.6");
  final _portController = TextEditingController(text: "9096");

  String _userCode = "";
  String _forwardAddress = "";
  int _forwardPort = 0;
  String _netTest = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: ListView(children: [
        Center(child: Text('Running on: $_platformVersion\n')),
        SizedBox(width: 32),
        ListTile(
          title: Row(children: [
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
                keyboardType: TextInputType.number,
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
          ]),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(SnackBar(content: Text("连接vpn")));

              final granted = await Permission.storage.request().isGranted;
              log("granted$granted");
              final ip = _ipController.text;
              final port = _portController.text;
              await Future.delayed(Duration(seconds: 1));
              final res = await ZkVpn.connect("$ip:$port");
              log("res$res");
              _userCode = res["userCode"];
              _forwardAddress = res["forwardAddress"];
              _forwardPort = res["forwardPort"];

              messenger.clearSnackBars();
              setState(() {});
            },
            child: Text('连接vpn'),
          ),
        ),
        if (_userCode.isNotEmpty)
          ListTile(
            title: Text(
              "$_userCode\n$_forwardAddress\n$_forwardPort",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        if (_forwardAddress.isNotEmpty)
          ListTile(
            title: ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(SnackBar(content: Text("测试网络")));

                final url = Uri.parse('http://$_forwardAddress/nettest');
                final res = await get(url);
                _netTest = res.body;

                messenger.clearSnackBars();
                setState(() {});
              },
              child: Text('nettest'),
            ),
          ),
        if (_netTest.isNotEmpty)
          ListTile(
            title: Text(
              "_netTest $_netTest",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
      ]),
    );
  }
}
