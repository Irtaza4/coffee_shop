import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/shop_view_model.dart';
import '../widgets/controls.dart';
import 'cart_view.dart';
import 'catalog_view.dart';

class ShopShell extends StatelessWidget {
  const ShopShell({super.key, required this.model});
  final ShopViewModel model;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
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
                _ => _ProfileView(key: const ValueKey('profile'), model: model),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
            child: SizedBox(
              height: 82,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 72,
                    child: ClipPath(
                      clipper: _NavClipper(),
                      child: ColoredBox(
                        color: Colors.black,
                        child: Row(
                          children: [
                            _navItem(0, Icons.home_outlined, 'Home'),
                            _navItem(
                              1,
                              Icons.favorite_border_rounded,
                              'Favorite',
                            ),
                            const SizedBox(width: 76),
                            _navItem(3, Icons.shopping_cart_outlined, 'Cart'),
                            _navItem(
                              4,
                              Icons.person_outline_rounded,
                              'Profile',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Pressable(
                      label: 'Explore',
                      onTap: () => model.selectTab(2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: model.tab == 2
                              ? const Color(0xFF7EC9EB)
                              : const Color(0xFF11151C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          Icons.center_focus_strong_rounded,
                          color: model.tab == 2 ? Colors.black : Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _navItem(int index, IconData icon, String title) => Expanded(
    child: Semantics(
      selected: model.tab == index,
      child: Pressable(
        label: title,
        onTap: () => model.selectTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: model.tab == index
                      ? const Color(0xFF9CD9F1)
                      : Colors.white,
                  size: 23,
                ),
                if (index == 3 && model.cartCount > 0)
                  Positioned(
                    right: -9,
                    top: -5,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(model.cartCount),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9CD9F1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '${model.cartCount}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: model.tab == index
                    ? const Color(0xFF9CD9F1)
                    : Colors.white70,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final center = size.width / 2;
    return Path()
      ..moveTo(36, 0)
      ..lineTo(center - 68, 0)
      ..cubicTo(center - 39, 0, center - 43, 63, center, 63)
      ..cubicTo(center + 43, 63, center + 39, 0, center + 68, 0)
      ..lineTo(size.width - 36, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 36)
      ..quadraticBezierTo(size.width, size.height, size.width - 36, size.height)
      ..lineTo(36, size.height)
      ..quadraticBezierTo(0, size.height, 0, 36)
      ..quadraticBezierTo(0, 0, 36, 0)
      ..close();
  }

  @override
  bool shouldReclip(_NavClipper oldClipper) => false;
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
