import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:macos_layover_email/presentation/widgets/banner_controller.dart';
import 'package:macos_layover_email/presentation/widgets/email_banner.dart';

void main() {
  late BannerController controller;
  final channel = const MethodChannel('window_manager');
  final overlayChannel =
      const MethodChannel('com.faizan.macosLayoverEmail/overlay');
  final calls = <String>[];
  final overlayCalls = <String>[];

  setUp(() {
    controller = BannerController();
    calls.clear();
    overlayCalls.clear();
    // Swallow window_manager platform calls (setIgnoreMouseEvents/setPosition).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      // bool-returning queries used internally by window_manager.
      if (call.method.startsWith('is')) return false;
      return null;
    });
    // Native overlay channel (showOverlay/hideOverlay).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(overlayChannel, (call) async {
      overlayCalls.add(call.method);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(overlayChannel, null);
    controller.dispose();
  });

  Widget wrap() => MaterialApp(
        home: Material(
          color: Colors.transparent,
          child: EmailBanner(controller: controller),
        ),
      );

  testWidgets('hidden until an email arrives', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text('Hello there'), findsNothing);
    expect(find.byIcon(Icons.cancel), findsNothing);
  });

  testWidgets('shows parrot animation, sender, and subject', (tester) async {
    await tester.pumpWidget(wrap());

    controller.show(subject: 'Hello there', from: 'sender@example.com');
    await tester.pump(); // process stream
    await tester.pump(); // rebuild visible

    expect(find.byType(Lottie), findsOneWidget);
    expect(find.text('Hello there'), findsOneWidget);
    expect(find.text('sender@example.com'), findsOneWidget);
    // Window was asked to become interactive and show natively.
    expect(calls, contains('setIgnoreMouseEvents'));
    expect(overlayCalls, contains('showOverlay'));
  });

  testWidgets('tapping the banner dismisses it', (tester) async {
    await tester.pumpWidget(wrap());

    controller.show(subject: 'Dismiss me', from: 'x@y.com');
    await tester.pump();
    await tester.pump();
    expect(find.text('Dismiss me'), findsOneWidget);

    await tester.tap(find.text('Dismiss me'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Dismiss me'), findsNothing);
    expect(overlayCalls, contains('hideOverlay'));
  });
}
