import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/main.dart';

/// Boots the real app widget tree and checks the start screen renders with
/// translations and every platform card.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    // receive_sharing_intent: no shared items at startup.
    messenger.setMockMethodCallHandler(
        const MethodChannel('receive_sharing_intent/messages'),
        (call) async => call.method == 'getInitialMedia' ? '[]' : null);
    messenger.setMockStreamHandler(
        const EventChannel('receive_sharing_intent/events-media'),
        MockStreamHandler.inline(onListen: (_, __) {}));
  });

  testWidgets('start screen shows every platform', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Social Status Saver'), findsWidgets);
    expect(find.text('Select app to view Status'), findsOneWidget);
    for (final label in [
      'View Status of WhatsApp Messenger',
      'View Status of WhatsApp Business',
      'View Instagram Media',
      'View Facebook Media',
      'View TikTok Media',
    ]) {
      await tester.scrollUntilVisible(find.text(label), 200);
      expect(find.text(label), findsOneWidget);
    }
  });
}
