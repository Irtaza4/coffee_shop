import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controls.dart';

/// A floating dock. Selection always occupies the raised center position.
/// During a drag, positions stay fixed until release so targets never move
/// away from the finger.
class FloatingTabBar extends StatefulWidget {
  const FloatingTabBar({
    super.key,
    required this.selected,
    required this.cartCount,
    required this.onSelected,
  });
  final int selected, cartCount;
  final ValueChanged<int> onSelected;
  @override
  State<FloatingTabBar> createState() => _FloatingTabBarState();
}

class _FloatingTabBarState extends State<FloatingTabBar> {
  static const labels = ['Home', 'Favorite', 'Explore', 'Cart', 'Profile'];
  static const icons = [
    Icons.home_outlined,
    Icons.favorite_border_rounded,
    Icons.center_focus_strong_rounded,
    Icons.shopping_cart_outlined,
    Icons.person_outline_rounded,
  ];
  List<int>? _dragOrder;
  double? _dragX;
  int? _hovered;
  bool _cancelled = false;
  List<int> get _order =>
      _dragOrder ??
      List.generate(5, (slot) => (widget.selected + slot - 2 + 5) % 5);

  void _move(double x, double width) {
    final slot = (x / (width / 5)).floor().clamp(0, 4);
    final next = _order[slot];
    if (_hovered != next) HapticFeedback.selectionClick();
    setState(() {
      _dragX = x.clamp(32, width - 32);
      _hovered = next;
    });
  }

  void _finish({bool cancelled = false}) {
    final next = _hovered;
    setState(() {
      _dragOrder = null;
      _dragX = null;
      _hovered = null;
    });
    if (!cancelled && !_cancelled && next != null && next != widget.selected) {
      widget.onSelected(next);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth, cell = width / 5;
      final order = _order;
      final active = _hovered ?? widget.selected;
      return Listener(
        onPointerDown: (_) => _cancelled = false,
        onPointerCancel: (_) => _cancelled = true,
        child: Semantics(
          label: 'Tab navigation',
          hint: 'Swipe across the dock and release to switch tabs',
          child: GestureDetector(
            key: const ValueKey('floating-tab-dock'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              _dragOrder = List.of(_order);
              _move(details.localPosition.dx, width);
            },
            onHorizontalDragUpdate: (details) =>
                _move(details.localPosition.dx, width),
            onHorizontalDragEnd: (_) => _finish(),
            onHorizontalDragCancel: () => _finish(cancelled: true),
            child: SizedBox(
              height: 88,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 72,
                    child: PhysicalShape(
                      clipper: _DockClipper(),
                      color: Colors.black,
                      elevation: 10,
                      shadowColor: Colors.black.withValues(alpha: .25),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (int tab = 0; tab < 5; tab++)
                    if (tab != widget.selected)
                      AnimatedPositioned(
                        key: ValueKey('tab-position-$tab'),
                        duration: _dragOrder != null
                            ? Duration.zero
                            : const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                        left: order.indexOf(tab) * cell,
                        bottom: 0,
                        width: cell,
                        height: 72,
                        child: Semantics(
                          selected: false,
                          child: Pressable(
                            label: labels[tab],
                            onTap: () => widget.onSelected(tab),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 120),
                              opacity: _hovered == tab ? .25 : 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _icon(tab, Colors.white),
                                  const SizedBox(height: 5),
                                  Text(
                                    labels[tab],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  AnimatedPositioned(
                    duration: _dragOrder != null
                        ? Duration.zero
                        : const Duration(milliseconds: 380),
                    curve: Curves.easeOutBack,
                    left: (_dragX ?? width / 2) - 32,
                    top: 0,
                    child: Semantics(
                      selected: true,
                      label: labels[active],
                      button: true,
                      onIncrease: () =>
                          widget.onSelected((widget.selected + 1) % 5),
                      onDecrease: () =>
                          widget.onSelected((widget.selected + 4) % 5),
                      child: ExcludeSemantics(
                        child: AnimatedScale(
                          scale: _dragOrder == null ? 1 : 1.1,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            key: ValueKey('center-tab-$active'),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7EC9EB),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: _icon(active, Colors.black),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  labels[active],
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _icon(int tab, Color color) => Stack(
    key: ValueKey(tab),
    clipBehavior: Clip.none,
    children: [
      Icon(icons[tab], color: color, size: 23),
      if (tab == 3 && widget.cartCount > 0)
        Positioned(
          right: -10,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFD5EFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${widget.cartCount}',
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
    ],
  );
}

class _DockClipper extends CustomClipper<Path> {
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
  bool shouldReclip(_DockClipper oldClipper) => false;
}
