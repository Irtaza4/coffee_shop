import 'package:flutter/material.dart';

@immutable
class Coffee {
  const Coffee({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.color,
    required this.hue,
    required this.description,
  });
  final String id, name, category, description;
  final double price, rating, hue;
  final Color color;
}

enum CupSize {
  small('S', 'Small', 237, -1),
  medium('M', 'Medium', 355, -.5),
  large('L', 'Large', 473, 0),
  extraLarge('XL', 'Extra large', 591, 1);

  const CupSize(this.label, this.title, this.milliliters, this.surcharge);
  final String label, title;
  final int milliliters;
  final double surcharge;
}

@immutable
class CartItem {
  const CartItem({
    required this.coffee,
    required this.size,
    required this.quantity,
  });
  final Coffee coffee;
  final CupSize size;
  final int quantity;
  String get key => '${coffee.id}-${size.name}';
  double get unitPrice => coffee.price + size.surcharge;
  double get total => unitPrice * quantity;
  CartItem withQuantity(int value) =>
      CartItem(coffee: coffee, size: size, quantity: value);
}
