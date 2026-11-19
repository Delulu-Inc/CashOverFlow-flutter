import 'dart:io';

import 'package:cash_overflow/app/app.dart';
import 'package:cash_overflow/app/app_dependencies.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_backend.dart';

/// Loads the Roboto files shipped with the Flutter SDK so text is measured
/// like on the web build (where `Inter` also falls back to Roboto).
///
/// Returns `false` when the SDK fonts cannot be found.
Future<bool> loadProductionFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return false;

  final dir = Directory('$flutterRoot/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) return false;

  final files = dir.listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last.toLowerCase();
    return name.startsWith('roboto-') && name.endsWith('.ttf');
  }).toList();
  if (files.isEmpty) return false;

  for (final family in const ['Roboto', 'Inter', 'inter']) {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = file.readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
  return true;
}

/// Pumps the whole app at [size], opened on [route].
Future<FakeBackend> pumpCashOverflowApp(
  WidgetTester tester, {
  String route = '/',
  Size size = const Size(1440, 900),
  bool signedIn = true,
  String role = 'Owner',
}) async {
  SharedPreferences.setMockInitialValues({
    if (signedIn) 'auth_token': 'test-token',
  });

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  tester.binding.platformDispatcher.defaultRouteNameTestValue = route;
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

  final backend = FakeBackend(role: role);
  await tester.pumpWidget(
    CashOverflowApp(
      dependencies: AppDependencies.create(httpClient: backend.client),
    ),
  );
  await settle(tester);
  return backend;
}

/// Lets futures, animations and post-frame callbacks complete.
Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
}
