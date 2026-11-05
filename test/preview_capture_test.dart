import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_shop/main.dart';

void main() {
  testWidgets('capture app previews', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final font = FontLoader('Manrope');
    for (final weight in [400, 500, 600, 700]) {
      font.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
    }
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const MyApp()));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/coffee-cup.png'),
        key.currentContext!,
      );
      await precacheImage(
        const AssetImage('assets/images/iced-coffee.png'),
        key.currentContext!,
      );
    });
    Future<void> capture(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build/previews').create(recursive: true);
        await File(
          'build/previews/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('welcome');
    await slide(tester, 'Get Started');
    await tester.pumpAndSettle();
    await capture('home');
    await tester.tap(find.text('Explore all'));
    await tester.pumpAndSettle();
    await capture('explore');
    await tester.tap(find.text('Brew\nNest'));
    await tester.pumpAndSettle();
    await capture('details');
    await slide(tester, 'Add To Cart');
    await tester.pumpAndSettle();
    await tester.tap(find.text('VIEW CART'));
    await tester.pumpAndSettle();
    await capture('cart');
    await slide(tester, 'Checkout');
    await tester.pumpAndSettle();
    await capture('checkout');
  });
}

Future<void> slide(WidgetTester tester, String title) async {
  final handle = find.byKey(ValueKey('slide-handle-$title'));
  await tester.drag(handle, const Offset(600, 0));
  await tester.pumpAndSettle();
}
