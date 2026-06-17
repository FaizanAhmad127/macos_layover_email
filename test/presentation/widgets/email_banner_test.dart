import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_layover_email/presentation/widgets/banner_controller.dart';
import 'package:macos_layover_email/presentation/widgets/email_banner.dart';

void main() {
  late BannerController controller;
  final channel = const MethodChannel('window_manager');
  final calls = <String>[];

  setUp(() {
    controller = BannerController();
    calls.clear();
    // Swallow window_manager platform calls (show/hide/setIgnoreMouseEvents).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      // bool-returning queries used internally by show()/hide().
      if (call.method.startsWith('is')) return false;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
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

  testWidgets('shows email icon, sender, subject and close button',
      (tester) async {
    await tester.pumpWidget(wrap());

    controller.show(subject: 'Hello there', from: 'sender@example.com');
    await tester.pump(); // process stream
    await tester.pump(); // rebuild visible

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.text('Hello there'), findsOneWidget);
    expect(find.text('sender@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
    // Window was asked to become interactive and show.
    expect(calls, contains('setIgnoreMouseEvents'));
    expect(calls, contains('show'));
  });

  testWidgets('tapping the close button dismisses the banner', (tester) async {
    await tester.pumpWidget(wrap());

    controller.show(subject: 'Dismiss me', from: 'x@y.com');
    await tester.pump();
    await tester.pump();
    expect(find.text('Dismiss me'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pump();
    await tester.pump();

    expect(find.text('Dismiss me'), findsNothing);
    expect(calls, contains('hide'));
  });
}
