import 'package:flutter/material.dart';
import '../viewmodels/shop_view_model.dart';
import 'onboarding_view.dart';
import 'shop_shell.dart';

/// Keeps the home layout and its images ready before the welcome screen exits.
class WelcomeFlow extends StatefulWidget {
  const WelcomeFlow({super.key, required this.model});
  final ShopViewModel model;
  @override
  State<WelcomeFlow> createState() => _WelcomeFlowState();
}

class _WelcomeFlowState extends State<WelcomeFlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: widget.model.started ? 1 : 0,
  );
  late final Animation<double> _incoming = _transition.drive(
    CurveTween(curve: const Interval(.12, 1, curve: Curves.easeOutCubic)),
  );
  late final Animation<double> _outgoing = _transition.drive(
    CurveTween(curve: const Interval(0, .8, curve: Curves.easeInOutCubic)),
  );
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onShopChanged);
    _transition.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transition.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 650);
  }

  void _onShopChanged() {
    if (!widget.model.started || _leaving || _transition.isCompleted) return;
    setState(() => _leaving = true);
    _transition.forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.model.removeListener(_onShopChanged);
    _transition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white,
    child: ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: !_transition.isCompleted,
            child: ExcludeSemantics(
              excluding: !_transition.isCompleted,
              child: TickerMode(
                enabled: widget.model.started,
                child: FadeTransition(
                  key: const ValueKey('home-entrance'),
                  opacity: _incoming,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(.055, 0),
                      end: Offset.zero,
                    ).animate(_incoming),
                    child: RepaintBoundary(
                      child: ListenableBuilder(
                        listenable: widget.model,
                        builder: (context, _) => ShopShell(model: widget.model),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!_transition.isCompleted)
            IgnorePointer(
              ignoring: _leaving,
              child: ExcludeSemantics(
                excluding: _leaving,
                child: TickerMode(
                  enabled: !_leaving,
                  child: FadeTransition(
                    key: const ValueKey('welcome-exit'),
                    opacity: ReverseAnimation(_outgoing),
                    child: SlideTransition(
                      position: Tween(
                        begin: Offset.zero,
                        end: const Offset(-.055, 0),
                      ).animate(_outgoing),
                      child: RepaintBoundary(
                        child: OnboardingView(model: widget.model),
                      ),
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
