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
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      _float.stop();
    } else {
      if (!_initialized) _entrance.forward();
      if (!_float.isAnimating) _float.repeat(reverse: true);
    }
    _initialized = true;
  }

  Animation<double> _phase(double start, double end) => _entrance.drive(
    CurveTween(curve: Interval(start, end, curve: Curves.easeOutCubic)),
  );

  Widget _reveal(
    String name,
    double start,
    double end,
    Widget child, {
    double rise = 30,
    double scale = .95,
  }) {
    final phase = _phase(start, end);
    return AnimatedBuilder(
      animation: phase,
      builder: (context, _) => IgnorePointer(
        ignoring: phase.value < .95,
        child: FadeTransition(
          key: ValueKey('splash-$name'),
          opacity: phase,
          child: Transform.translate(
            offset: Offset(0, rise * (1 - phase.value)),
            child: Transform.scale(
              scale: scale + (1 - scale) * phase.value,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFFB8E6F8)),
        AnimatedBuilder(
          animation: Listenable.merge([_float, _entrance]),
          builder: (context, child) {
            final progress = _phase(0, .7).value;
            return Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 65 * (1 - progress)),
                child: Transform.scale(
                  scale: MediaQuery.disableAnimationsOf(context)
                      ? 1
                      : 1 + .16 * (1 - progress) + .025 * _float.value,
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(
            'assets/images/iced-coffee.png',
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, synchronous) =>
                AnimatedOpacity(
                  opacity: synchronous || frame != null ? 1 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 450),
                  child: child,
                ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              children: [
                SizedBox(height: constraints.maxHeight * .095),
                _reveal(
                  'eyebrow',
                  .12,
                  .43,
                  const Text(
                    'IT’S TIME FOR',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _reveal(
                          'brand',
                          .24,
                          .62,
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
                          rise: 40,
                          scale: .8,
                        ),
                        _reveal(
                          'coffee',
                          .33,
                          .7,
                          const Text(
                            ' Coffee',
                            style: TextStyle(
                              fontSize: 43,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _reveal(
                  'experience',
                  .44,
                  .8,
                  const Text(
                    'Experience',
                    style: TextStyle(
                      fontSize: 43,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.8,
                    ),
                  ),
                  rise: 40,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                  child: _reveal(
                    'action',
                    .62,
                    1,
                    SlideAction(
                      title: 'Get Started',
                      resetAfterCompletion: false,
                      onTap: widget.model.start,
                    ),
                    rise: 60,
                    scale: .9,
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
