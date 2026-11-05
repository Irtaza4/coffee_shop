import 'package:flutter/material.dart';
import '../viewmodels/shop_view_model.dart';
import '../widgets/coffee_cup.dart';
import '../widgets/controls.dart';
import 'checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key, required this.model});
  final ShopViewModel model;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      PageHeading('Cart', onBack: () => model.selectTab(0)),
      if (model.cart.isEmpty)
        Expanded(
          child: EmptyState(
            icon: Icons.shopping_basket_outlined,
            title: 'Your next cup is waiting',
            message: 'Find something delicious and make it yours.',
            action: SlideAction(
              title: 'Explore coffee',
              onTap: () => model.selectTab(2),
            ),
          ),
        )
      else
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(42),
            ),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    itemCount: model.cart.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final item = model.cart[index];
                      return Row(
                        children: [
                          Container(
                            width: 74,
                            height: 85,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: item.coffee.color,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: CoffeeCup(coffee: item.coffee),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.coffee.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -.5,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${item.size.title}, ${item.size.milliliters}ml',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    RoundButton(
                                      icon: Icons.add,
                                      onTap: () =>
                                          model.changeQuantity(item.key, 1),
                                      label: 'Add ${item.coffee.name}',
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    RoundButton(
                                      icon: item.quantity == 1
                                          ? Icons.delete_outline
                                          : Icons.remove,
                                      onTap: () =>
                                          model.changeQuantity(item.key, -1),
                                      label: 'Remove ${item.coffee.name}',
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text(
                              money(item.total),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(17),
                  padding: const EdgeInsets.all(23),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Amount'),
                          Text(
                            money(model.delivery),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Amount'),
                                const SizedBox(height: 4),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  child: Text(
                                    money(model.total),
                                    key: ValueKey(model.total),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 90,
                            width: 80,
                            child: CoffeeCup(
                              coffee: model.cart.first.coffee,
                              angle: .2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 0, 17, 18),
                  child: SlideAction(
                    title: 'Checkout',
                    onTap: () => Navigator.push(
                      context,
                      coffeeRoute(CheckoutView(model: model)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
