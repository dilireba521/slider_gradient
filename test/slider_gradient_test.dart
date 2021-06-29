import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_gradient/slider_gradient.dart';

void main() {
  const MethodChannel channel = MethodChannel('slider_gradient');

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
    expect(await SliderGradient.platformVersion, '42');
  });
}
