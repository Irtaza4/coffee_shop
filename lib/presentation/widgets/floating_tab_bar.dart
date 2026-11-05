import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controls.dart';

/// Fixed tab slots with a moving cutout and raised selection highlight.
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
  bool _dragging = false;
  int? _hovered;
  bool _cancelled = false;
  void _move(double x, double width) {
    final slot = (x / (width / 5)).floor().clamp(0, 4);
    final next = slot;
    if (_hovered != next) HapticFeedback.selectionClick();
    setState(() {
      _dragging = true;
      _hovered = next;
    });
  }

  void _finish({bool cancelled = false}) {
    final next = _hovered;
    setState(() {
      _dragging = false;
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
      final active = _hovered ?? widget.selected;
      final diameter = (cell - 4).clamp(48.0, 64.0);
      final duration = MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(milliseconds: _dragging ? 140 : 380);
      return Listener(
        onPointerDown: (_) => _cancelled = false,
        onPointerCancel: (_) => _cancelled = true,
        child: Semantics(
          label: 'Tab navigation',
          hint: 'Swipe across the dock and release to switch tabs',
          child: GestureDetector(
            key: const ValueKey('floating-tab-dock'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) =>
                _move(details.localPosition.dx, width),
            onHorizontalDragUpdate: (details) =>
                _move(details.localPosition.dx, width),
            onHorizontalDragEnd: (_) => _finish(),
            onHorizontalDragCancel: () => _finish(cancelled: true),
            child: SizedBox(
              height: 88,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: active.toDouble(),
                  end: active.toDouble(),
                ),
                duration: duration,
                curve: Curves.easeOutCubic,
                builder: (context, position, _) {
                  final center = (position + .5) * cell;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 72,
                        child: PhysicalShape(
                          key: const ValueKey('dock-cutout'),
                          clipper: _DockClipper(
                            center: center,
                            halfWidth: cell * .88,
                            depth: diameter - 1,
                          ),
                          color: Colors.black,
                          elevation: 10,
                          shadowColor: Colors.black.withValues(alpha: .25),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      Positioned(
                        left: center - diameter / 2,
                        top: 0,
                        child: IgnorePointer(
                          child: Container(
                            key: const ValueKey('tab-highlight'),
                            width: diameter,
                            height: diameter,
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
                          ),
                        ),
                      ),
                      for (int tab = 0; tab < 5; tab++)
                        AnimatedPositioned(
                          key: ValueKey('tab-position-$tab'),
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          left: tab * cell,
                          top: tab == active ? 0 : 16,
                          width: cell,
                          height: tab == active ? diameter : 72,
                          child: Semantics(
                            selected: tab == widget.selected,
                            child: Pressable(
                              label: labels[tab],
                              onTap: () => widget.onSelected(tab),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _icon(
                                    tab,
                                    tab == active ? Colors.black : Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    labels[tab],
                                    style: TextStyle(
                                      color: tab == active
                                          ? Colors.black
                                          : Colors.white70,
                                      fontSize: 9,
                                      fontWeight: tab == active
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
  const _DockClipper({
    required this.center,
    required this.halfWidth,
    required this.depth,
  });
  final double center, halfWidth, depth;
  @override
  Path getClip(Size size) {
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(36)),
      );
    // Subtract the dip rather than intersecting the rounded corners. This also
    // keeps the first and last tab's cutouts valid at the edges of the dock.
    final dip = Path()
      ..moveTo(center - halfWidth, -20)
      ..lineTo(center - halfWidth, 0)
      ..cubicTo(
        center - halfWidth * .57,
        0,
        center - halfWidth * .63,
        depth,
        center,
        depth,
      )
      ..cubicTo(
        center + halfWidth * .63,
        depth,
        center + halfWidth * .57,
        0,
        center + halfWidth,
        0,
      )
      ..lineTo(center + halfWidth, -20)
      ..close();
    return Path.combine(PathOperation.difference, body, dip);
  }

  @override
  bool shouldReclip(_DockClipper oldClipper) =>
      center != oldClipper.center ||
      halfWidth != oldClipper.halfWidth ||
      depth != oldClipper.depth;
}
