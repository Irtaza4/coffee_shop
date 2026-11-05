import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_shop/data/repositories/coffee_repository.dart';
import 'package:coffee_shop/presentation/viewmodels/shop_view_model.dart';
import 'package:coffee_shop/presentation/views/onboarding_view.dart';

void main() {
  testWidgets(
    'splash reveals heading before action and finishes the entrance',
    (tester) async {
      final model = ShopViewModel(LocalCoffeeRepository());
      addTearDown(model.dispose);
      await tester.pumpWidget(MaterialApp(home: OnboardingView(model: model)));
      double opacity(String name) => tester
          .widget<FadeTransition>(find.byKey(ValueKey('splash-$name')))
          .opacity
          .value;
      expect(opacity('eyebrow'), 0);
      expect(opacity('brand'), 0);
      expect(opacity('action'), 0);
      await tester.pump(const Duration(milliseconds: 650));
      expect(opacity('eyebrow'), greaterThan(opacity('brand')));
      expect(opacity('brand'), greaterThan(0));
      expect(opacity('action'), 0);
      await tester.pump(const Duration(milliseconds: 650));
      expect(opacity('experience'), 1);
      expect(opacity('action'), inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 400));
      for (final name in [
        'eyebrow',
        'brand',
        'coffee',
        'experience',
        'action',
      ]) {
        expect(opacity(name), 1);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('reduced motion reveals splash immediately', (tester) async {
    final model = ShopViewModel(LocalCoffeeRepository());
    addTearDown(model.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OnboardingView(model: model),
        ),
      ),
    );
    for (final name in ['eyebrow', 'brand', 'coffee', 'experience', 'action']) {
      expect(
        tester
            .widget<FadeTransition>(find.byKey(ValueKey('splash-$name')))
            .opacity
            .value,
        1,
      );
    }
    await tester.pumpWidget(const SizedBox());
  });
}
