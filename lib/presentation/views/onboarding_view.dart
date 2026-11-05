import 'package:flutter/material.dart';
import '../viewmodels/shop_view_model.dart';
import '../widgets/controls.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key, required this.model});
  final ShopViewModel model;
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _float,
          builder: (context, child) => Transform.scale(
            scale: MediaQuery.disableAnimationsOf(context)
                ? 1
                : 1 + .025 * _float.value,
            child: child,
          ),
          child: Image.asset(
            'assets/images/iced-coffee.png',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              children: [
                SizedBox(height: constraints.maxHeight * .095),
                const Text(
                  'IT’S TIME FOR',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DBAEE),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Cuppio',
                            style: TextStyle(
                              fontSize: 43,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: -1.8,
                            ),
                          ),
                        ),
                        const Text(
                          ' Coffee',
                          style: TextStyle(
                            fontSize: 43,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Experience',
                  style: TextStyle(
                    fontSize: 43,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.8,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                  child: SlideAction(
                    title: 'Get Started',
                    onTap: widget.model.start,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
