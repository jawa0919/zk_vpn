import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zk_vpn/zk_vpn.dart';

void main() {
  const MethodChannel channel = MethodChannel('zk_vpn');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ZkVpn.platformVersion, '42');
  });
}
