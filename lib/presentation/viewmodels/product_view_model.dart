import 'package:flutter/foundation.dart';
import '../../domain/models/coffee.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel(this.coffee);
  final Coffee coffee;
  CupSize _size = CupSize.large;
  int _quantity = 1;
  CupSize get size => _size;
  int get quantity => _quantity;
  double get total => (coffee.price + size.surcharge) * quantity;
  void selectSize(CupSize value) {
    _size = value;
    notifyListeners();
  }

  void changeQuantity(int delta) {
    final next = _quantity + delta;
    if (next < 1 || next > 99) return;
    _quantity = next;
    notifyListeners();
  }
}
