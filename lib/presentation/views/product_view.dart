import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/coffee.dart';
import '../viewmodels/product_view_model.dart';
import '../viewmodels/shop_view_model.dart';
import '../widgets/coffee_cup.dart';
import '../widgets/controls.dart';

class ProductView extends StatefulWidget {
  const ProductView({
    super.key,
    required this.coffee,
    required this.shop,
    required this.heroTag,
  });
  final Coffee coffee;
  final ShopViewModel shop;
  final String heroTag;
  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late final ProductViewModel model = ProductViewModel(widget.coffee);
  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListenableBuilder(
        listenable: model,
        builder: (context, _) => Column(
          children: [
            PageHeading(
              'Details',
              onBack: () => Navigator.pop(context),
              trailing: ListenableBuilder(
                listenable: widget.shop,
                builder: (context, _) => RoundButton(
                  icon: widget.shop.isFavorite(widget.coffee)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onTap: () => widget.shop.toggleFavorite(widget.coffee),
                  label: 'Toggle favorite',
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.coffee.name.replaceFirst(' ', '\n'),
                                  style: const TextStyle(
                                    fontSize: 39,
                                    height: 1.05,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -1.7,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  '★ ${widget.coffee.rating}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: (constraints.maxHeight * .58).clamp(
                            280.0,
                            420.0,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 27,
                                  right: 5,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: CupSize.values
                                      .map(
                                        (size) => Semantics(
                                          selected: size == model.size,
                                          child: Pressable(
                                            label:
                                                '${size.title}, ${size.milliliters} milliliters',
                                            onTap: () => model.selectSize(size),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 260,
                                              ),
                                              curve: Curves.easeOut,
                                              width: 57,
                                              height: 57,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: size == model.size
                                                    ? Colors.black
                                                    : AppTheme.mist,
                                              ),
                                              child: Text(
                                                size.label,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: size == model.size
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedScale(
                                      duration: const Duration(
                                        milliseconds: 450,
                                      ),
                                      curve: Curves.easeOutBack,
                                      scale: .8 + model.size.index * .065,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          8,
                                          20,
                                        ),
                                        child: CoffeeCup(
                                          coffee: widget.coffee,
                                          heroTag: widget.heroTag,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 25,
                                      right: 25,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 14,
                                            sigmaY: 14,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 18,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  widget.coffee.color
                                                      .withValues(alpha: .8),
                                                  Colors.white.withValues(
                                                    alpha: .5,
                                                  ),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: .7,
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            child: Row(
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Foamed\nMilk',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ),
                                                AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 250,
                                                  ),
                                                  child: Text(
                                                    '${model.size.milliliters}ml',
                                                    key: ValueKey(model.size),
                                                    style: const TextStyle(
                                                      fontSize: 27,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: -1,
                                                    ),
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
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: AppTheme.mist,
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(160, 65),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RoundButton(
                                icon: Icons.remove,
                                onTap: model.quantity > 1
                                    ? () => model.changeQuantity(-1)
                                    : null,
                                label: 'Decrease quantity',
                              ),
                              Column(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                    child: Text(
                                      model.quantity.toString().padLeft(2, '0'),
                                      key: ValueKey(model.quantity),
                                      style: const TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.w600,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      money(model.total),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              RoundButton(
                                icon: Icons.add,
                                onTap: model.quantity < 99
                                    ? () => model.changeQuantity(1)
                                    : null,
                                label: 'Increase quantity',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(27, 6, 27, 16),
                          child: Text(
                            widget.coffee.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A7E83),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: SlideAction(
                title: 'Add To Cart',
                icon: Icons.shopping_basket_outlined,
                onTap: () {
                  widget.shop.addToCart(
                    widget.coffee,
                    model.size,
                    model.quantity,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.coffee.name} added to your cart'),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        textColor: widget.coffee.color,
                        onPressed: () => widget.shop.selectTab(3),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
