import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ic_storage_space/ic_storage_space.dart';

void main() {
  const MethodChannel channel = MethodChannel('ic_storage_space');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel.name, null);
  });

  test('getPlatformVersion', () async {
    expect(await IcStorageSpace.platformVersion, '42');
  });
}
