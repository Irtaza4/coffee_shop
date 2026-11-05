import 'package:flutter/foundation.dart';
import '../../data/repositories/coffee_repository.dart';
import '../../domain/models/coffee.dart';

class ShopViewModel extends ChangeNotifier {
  ShopViewModel(CoffeeRepository repository)
    : coffees = repository.getCoffees();
  final List<Coffee> coffees;
  final Set<String> _favorites = {};
  final List<CartItem> _cart = [];
  bool _started = false;
  int _tab = 0;
  String _category = 'All', _query = '';
  bool _topRated = false;
  String _address = '2464 Royal Ln, New Jersey';
  String _payment = 'Credit card';
  int _orders = 0;
  bool get started => _started;
  int get tab => _tab;
  String get category => _category;
  String get query => _query;
  bool get topRated => _topRated;
  String get address => _address;
  String get payment => _payment;
  int get orders => _orders;
  List<CartItem> get cart => List.unmodifiable(_cart);
  int get cartCount => _cart.fold(0, (n, item) => n + item.quantity);
  double get subtotal => _cart.fold(0, (n, item) => n + item.total);
  double get delivery => _cart.isEmpty ? 0 : 2.5;
  double get total => subtotal + delivery;
  List<Coffee> get favorites => coffees.where((c) => isFavorite(c)).toList();
  List<Coffee> get filtered {
    final result = coffees
        .where(
          (c) =>
              (_category == 'All' || c.category == _category) &&
              c.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    if (_topRated) result.sort((a, b) => b.rating.compareTo(a.rating));
    return result;
  }

  bool isFavorite(Coffee coffee) => _favorites.contains(coffee.id);
  void start() {
    _started = true;
    notifyListeners();
  }

  void selectTab(int value) {
    _tab = value;
    notifyListeners();
  }

  void selectCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void search(String value) {
    _query = value;
    notifyListeners();
  }

  void toggleSort() {
    _topRated = !_topRated;
    notifyListeners();
  }

  void toggleFavorite(Coffee coffee) {
    if (!_favorites.add(coffee.id)) _favorites.remove(coffee.id);
    notifyListeners();
  }

  void addToCart(Coffee coffee, CupSize size, int quantity) {
    if (quantity < 1) return;
    final index = _cart.indexWhere(
      (item) => item.coffee.id == coffee.id && item.size == size,
    );
    if (index < 0) {
      _cart.add(CartItem(coffee: coffee, size: size, quantity: quantity));
    } else {
      _cart[index] = _cart[index].withQuantity(
        _cart[index].quantity + quantity,
      );
    }
    notifyListeners();
  }

  void changeQuantity(String key, int delta) {
    final index = _cart.indexWhere((item) => item.key == key);
    if (index < 0) return;
    final quantity = _cart[index].quantity + delta;
    if (quantity <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index] = _cart[index].withQuantity(quantity);
    }
    notifyListeners();
  }

  void updateAddress(String value) {
    if (value.trim().isNotEmpty) {
      _address = value.trim();
      notifyListeners();
    }
  }

  void selectPayment(String value) {
    _payment = value;
    notifyListeners();
  }

  bool placeDemoOrder() {
    if (_cart.isEmpty) return false;
    _orders++;
    _cart.clear();
    notifyListeners();
    return true;
  }
}
