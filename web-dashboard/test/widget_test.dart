import 'package:aquasecure_ai/app/aquasecure_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo alert enters and exits the critical threat state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AquaSecureApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('ALL SYSTEMS SECURE'), findsOneWidget);
    expect(find.text('RUN ATTACK DEMO'), findsOneWidget);

    await tester.tap(find.text('RUN ATTACK DEMO'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('CRITICAL THREAT DETECTED'), findsOneWidget);
    expect(find.text('Why this was flagged'), findsOneWidget);
    expect(find.byKey(const Key('acknowledge-alert-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('acknowledge-alert-button')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ALL SYSTEMS SECURE'), findsOneWidget);
    expect(find.text('CRITICAL THREAT DETECTED'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
