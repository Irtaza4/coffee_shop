import 'package:flutter/material.dart';
import '../../domain/models/coffee.dart';

abstract interface class CoffeeRepository {
  List<Coffee> getCoffees();
}

class LocalCoffeeRepository implements CoffeeRepository {
  @override
  List<Coffee> getCoffees() => const [
    Coffee(
      id: 'brew',
      name: 'Brew Nest',
      category: 'Latte',
      price: 6,
      rating: 4.6,
      color: Color(0xFFD5EFFF),
      hue: 0,
      description:
          'Your little moment of calm. Rich espresso meets silky steamed milk, finished with a soft cloud of foam.',
    ),
    Coffee(
      id: 'steamy',
      name: 'Steamy Bean',
      category: 'Cappuccino',
      price: 5,
      rating: 4.4,
      color: Color(0xFFFFDCE2),
      hue: 135,
      description:
          'A beautifully balanced espresso with warm milk and a generous layer of velvety foam. A classic for a reason.',
    ),
    Coffee(
      id: 'latte',
      name: 'Latte Loop',
      category: 'Latte',
      price: 7,
      rating: 4.8,
      color: Color(0xFFE0DCFF),
      hue: 65,
      description:
          'Smooth, mellow and a little indulgent. A double shot of espresso wrapped in creamy milk with a hint of vanilla.',
    ),
    Coffee(
      id: 'smiths',
      name: 'Smiths Chips',
      category: 'Mocha',
      price: 6,
      rating: 4.6,
      color: Color(0xFFFFD8B2),
      hue: 195,
      description:
          'Chocolate, espresso and silky milk come together in this cozy favorite, topped with chocolate chips.',
    ),
    Coffee(
      id: 'java',
      name: 'Java Joy',
      category: 'Americano',
      price: 4,
      rating: 4.9,
      color: Color(0xFFFFEAB0),
      hue: 225,
      description:
          'Bright, bold and beautifully simple. Freshly pulled espresso and hot water let our signature roast shine.',
    ),
    Coffee(
      id: 'bean',
      name: 'Bean Wave',
      category: 'Mocha',
      price: 8,
      rating: 4.5,
      color: Color(0xFFE4FADD),
      hue: 285,
      description:
          'Ride a sweeter wave. Our signature espresso, white chocolate and steamed milk, made for slow mornings.',
    ),
  ];
}
