// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:as_built/main.dart';
import 'package:as_built/core/localization/translation_helper.dart';
import 'package:as_built/screens/auth/login_screen.dart';
import 'package:as_built/screens/help/help_screen.dart';
import 'package:as_built/providers/app_providers.dart';
import 'package:as_built/providers/permission_provider.dart';
import 'package:as_built/utils/map_launcher.dart';
import 'package:as_built/widgets/enhanced_drawer.dart';

Widget _buildTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('pt'),
      supportedLocales: const [Locale('pt'), Locale('en')],
      localizationsDelegates: const [
        TranslationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  testWidgets('App launches to login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AsBuiltApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify desktop app opens login screen.
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Help screen documentation tiles open a dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(const HelpScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);

    await tester.tap(find.text('Guia de Início Rápido'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  test('MapLauncher parses GPS coordinates with comma separator', () {
    final coordinates = MapLauncher.tryParseCoordinates('41,123456; -8,654321');

    expect(coordinates, isNotNull);
    expect(coordinates!.latitude, closeTo(41.123456, 0.000001));
    expect(coordinates.longitude, closeTo(-8.654321, 0.000001));
  });

  test('MapLauncher builds a Google Maps search URL', () {
    final uri = MapLauncher.buildMapsUri('Setor A Norte');

    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/search/');
    expect(uri.queryParameters['api'], '1');
    expect(uri.queryParameters['query'], 'Setor A Norte');
  });

  test('MapLauncher formats coordinates for persistence', () {
    final value = MapLauncher.formatCoordinates(41.1234567, -8.6543212);

    expect(value, '41.123457, -8.654321');
  });

  testWidgets('Sidebar help action selects help item',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));

    final container = ProviderContainer(
      overrides: [
        globalPermissionProvider.overrideWith((ref) => PermissionNotifier()),
        selectedProjectProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );

    addTearDown(container.dispose);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('pt'),
          supportedLocales: const [Locale('pt'), Locale('en')],
          localizationsDelegates: const [
            TranslationDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: Row(
              children: [
                AppSidebar(),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline).last);
    await tester.pumpAndSettle();

    expect(container.read(desktopSelectedItemProvider), DrawerMenuItemKey.help);
  });
}
