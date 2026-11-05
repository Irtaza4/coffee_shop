import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/models/coffee.dart';
import 'coffee_cup.dart';
import 'controls.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.coffee,
    required this.onOpen,
    required this.onFavorite,
    required this.favorite,
    required this.heroTag,
    this.large = false,
  });
  final Coffee coffee;
  final VoidCallback onOpen, onFavorite;
  final bool favorite, large;
  final String heroTag;
  @override
  Widget build(BuildContext context) => Pressable(
    label: 'View ${coffee.name}',
    onTap: onOpen,
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: coffee.color,
        borderRadius: BorderRadius.circular(large ? 38 : 28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: large ? -22 : -26,
            left: large ? 18 : 30,
            top: large ? 64 : 48,
            bottom: large ? 12 : 18,
            child: CoffeeCup(coffee: coffee, angle: .22, heroTag: heroTag),
          ),
          Positioned(
            left: large ? 24 : 16,
            top: large ? 24 : 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coffee.name.replaceFirst(' ', '\n'),
                  style: TextStyle(
                    fontSize: large ? 34 : 22,
                    height: 1.02,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${coffee.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Semantics(
              label: favorite
                  ? 'Unfavorite ${coffee.name}'
                  : 'Favorite ${coffee.name}',
              button: true,
              child: IconButton.filledTonal(
                onPressed: onFavorite,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .82),
                  minimumSize: const Size(38, 38),
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    favorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(favorite),
                    size: 18,
                    color: favorite ? const Color(0xFFB64969) : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .85),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            money(coffee.price),
                            style: TextStyle(
                              fontSize: large ? 18 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: large ? 56 : 43,
                        height: large ? 48 : 38,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.shopping_basket_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
