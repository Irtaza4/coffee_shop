import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/shop_view_model.dart';
import '../widgets/controls.dart';
import '../widgets/floating_tab_bar.dart';
import 'cart_view.dart';
import 'catalog_view.dart';

class ShopShell extends StatelessWidget {
  const ShopShell({super.key, required this.model});
  final ShopViewModel model;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: model.tab == 1 || model.tab == 2 ? 0 : 100,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                child: switch (model.tab) {
                  0 => CatalogView(key: const ValueKey('home'), model: model),
                  1 => CatalogView(
                    key: const ValueKey('favorites'),
                    model: model,
                    favorites: true,
                  ),
                  2 => CatalogView(
                    key: const ValueKey('explore'),
                    model: model,
                    explore: true,
                  ),
                  3 => CartView(key: const ValueKey('cart'), model: model),
                  _ => _ProfileView(
                    key: const ValueKey('profile'),
                    model: model,
                  ),
                },
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 10,
            child: FloatingTabBar(
              selected: model.tab,
              cartCount: model.cartCount,
              onSelected: model.selectTab,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({super.key, required this.model});
  final ShopViewModel model;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      PageHeading('Profile', onBack: () => model.selectTab(0)),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFD5EFFF),
              child: Text(
                'JW',
                style: TextStyle(
                  fontSize: 28,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Jenny Wilson',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            const Text(
              'A good day starts with coffee.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.mist,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('${model.orders}', 'Demo orders'),
                  _stat('${model.favorites.length}', 'Favorites'),
                  _stat('${model.cartCount}', 'In your cart'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.favorite_border_rounded),
              title: const Text('My favorites'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => model.selectTab(1),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('My cart'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => model.selectTab(3),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About Cuppio'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Cuppio Coffee',
                applicationVersion: '1.0.0',
                children: [
                  const Text(
                    'A coffee experience inspired by Ali Mortuja’s Coffee Shop design for Dashbloom. This demo stores your selections for the current session.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'MADE FOR YOUR DAILY RITUAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _stat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ],
  );
}
