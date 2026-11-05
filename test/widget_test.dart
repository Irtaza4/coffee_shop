import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_shop/main.dart';
import 'package:coffee_shop/data/repositories/coffee_repository.dart';
import 'package:coffee_shop/domain/models/coffee.dart';
import 'package:coffee_shop/presentation/viewmodels/shop_view_model.dart';
import 'package:coffee_shop/presentation/viewmodels/product_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Manrope');
    for (final weight in [400, 500, 600, 700]) {
      font.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
    }
    await font.load();
  });
  test(
    'cart merges matching sizes, keeps different sizes, and calculates totals',
    () {
      final shop = ShopViewModel(LocalCoffeeRepository());
      final coffee = shop.coffees.first;
      shop.addToCart(coffee, CupSize.large, 1);
      shop.addToCart(coffee, CupSize.large, 2);
      shop.addToCart(coffee, CupSize.small, 1);
      expect(shop.cart.length, 2);
      expect(shop.cartCount, 4);
      expect(shop.total, 25.5);
      shop.changeQuantity(shop.cart.last.key, -1);
      expect(shop.cart.length, 1);
      expect(shop.placeDemoOrder(), isTrue);
      expect(shop.cart, isEmpty);
      expect(shop.total, 0);
      expect(shop.orders, 1);
      expect(shop.placeDemoOrder(), isFalse);
      shop.dispose();
    },
  );
  test('filters, favorites and size pricing are independent', () {
    final shop = ShopViewModel(LocalCoffeeRepository());
    shop.selectCategory('Latte');
    shop.search('loop');
    expect(shop.filtered.single.name, 'Latte Loop');
    shop.toggleFavorite(shop.filtered.single);
    expect(shop.favorites.length, 1);
    shop.toggleFavorite(shop.filtered.single);
    expect(shop.favorites, isEmpty);
    final product = ProductViewModel(shop.coffees.first);
    product.changeQuantity(-1);
    expect(product.quantity, 1);
    product.selectSize(CupSize.extraLarge);
    product.changeQuantity(1);
    expect(product.total, 14);
    product.dispose();
    shop.dispose();
  });
  testWidgets('browse, customize, add to cart and complete demo checkout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    await slide(tester, 'Get Started');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Hello,\nJenny Wilson'), findsOneWidget);
    await tester.tap(find.text('Brew\nNest'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Details'), findsOneWidget);
    await tester.tap(find.text('XL'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('591ml'), findsOneWidget);
    await slide(tester, 'Add To Cart');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('VIEW CART'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Brew Nest'), findsOneWidget);
    await slide(tester, 'Checkout');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await slide(tester, 'Place Demo Order');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Happiness is brewing.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('compact screen and explore grid have no layout overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 2));
    await slide(tester, 'Get Started');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Explore all'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Explore'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Brew\nNest'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.takeException(), isNull);
  });
}

Future<void> slide(WidgetTester tester, String title) async {
  final handle = find.byKey(ValueKey('slide-handle-$title'));
  await tester.drag(handle, const Offset(600, 0));
  await tester.pumpAndSettle();
}
