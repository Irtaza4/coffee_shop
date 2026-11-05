import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/shop_view_model.dart';
import '../widgets/controls.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key, required this.model});
  final ShopViewModel model;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListenableBuilder(
        listenable: model,
        builder: (context, _) => Column(
          children: [
            PageHeading('Checkout', onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Address',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  _option(
                    icon: Icons.location_on_rounded,
                    title: model.address,
                    trailing: const Icon(Icons.edit_outlined, size: 22),
                    onTap: () => _editAddress(context),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  for (final method in ['Credit card', 'Paypal', 'Google Pay'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: _option(
                        icon: method == 'Credit card'
                            ? Icons.credit_card_rounded
                            : method == 'Paypal'
                            ? Icons.paypal_rounded
                            : Icons.account_balance_wallet_outlined,
                        title: method,
                        trailing: Icon(
                          model.payment == method
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: model.payment == method
                              ? AppTheme.ink
                              : Colors.grey,
                        ),
                        onTap: () => model.selectPayment(method),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF7FB),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Demo checkout • No payment will be charged.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF547487)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 19),
                      ),
                      Text(
                        money(model.total),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SlideAction(
                    title: 'Place Demo Order',
                    onTap: model.cart.isEmpty
                        ? null
                        : () {
                            if (!model.placeDemoOrder()) return;
                            Navigator.of(context).pushReplacement(
                              coffeeRoute(_OrderSuccess(model: model)),
                            );
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _option({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) => Pressable(
    onTap: onTap,
    label: title,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.mist,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
          const SizedBox(width: 9),
        ],
      ),
    ),
  );
  Future<void> _editAddress(BuildContext context) async {
    final controller = TextEditingController(text: model.address);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery address'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Enter your address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) model.updateAddress(result);
    // The dialog route must finish its exit animation before disposing its field.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
  }
}

class _OrderSuccess extends StatelessWidget {
  const _OrderSuccess({required this.model});
  final ShopViewModel model;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .4, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4FADD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 58),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Happiness is brewing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Your demo order is complete.\nNo payment was taken and no delivery is scheduled.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.6),
              ),
              const SizedBox(height: 36),
              SlideAction(
                title: 'Back to coffee',
                onTap: () {
                  model.selectTab(0);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
