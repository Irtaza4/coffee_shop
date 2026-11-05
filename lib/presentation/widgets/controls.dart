import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

String money(double amount) => '\$${amount.toStringAsFixed(2)}';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.label,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? label;
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    enabled: widget.onTap != null,
    child: AnimatedScale(
      scale: _down ? .95 : 1,
      duration: const Duration(milliseconds: 140),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onHighlightChanged: (value) => setState(() => _down = value),
          onTap: widget.onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  widget.onTap!();
                },
          child: widget.child,
        ),
      ),
    ),
  );
}

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.dark = false,
    this.size = 48,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final String label;
  final bool dark;
  final double size;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Pressable(
      label: label,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: dark ? AppTheme.ink : Colors.white,
          shape: BoxShape.circle,
          border: dark ? null : Border.all(color: const Color(0xFFE8EBEF)),
        ),
        child: Icon(
          icon,
          size: size * .43,
          color: onTap == null
              ? Colors.grey
              : dark
              ? Colors.white
              : AppTheme.ink,
        ),
      ),
    ),
  );
}

/// A drag-only action, with an accessible activation alternative.
class SlideAction extends StatefulWidget {
  const SlideAction({
    super.key,
    required this.title,
    required this.onTap,
    this.icon = Icons.arrow_forward_ios_rounded,
    this.resetAfterCompletion = true,
  });
  final String title;
  final VoidCallback? onTap;
  final IconData icon;
  final bool resetAfterCompletion;
  @override
  State<SlideAction> createState() => _SlideActionState();
}

class _SlideActionState extends State<SlideAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  bool _committing = false;
  bool _cancelled = false;
  bool _focused = false;
  bool get _enabled => widget.onTap != null && !_committing;

  @override
  void didUpdateWidget(SlideAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap == null || widget.title != oldWidget.title) {
      _progress.value = 0;
    }
  }

  Future<void> _complete() async {
    if (!_enabled) return;
    setState(() => _committing = true);
    final action = widget.onTap!;
    HapticFeedback.mediumImpact();
    await _progress.animateTo(1, curve: Curves.easeOutCubic);
    if (!mounted) return;
    if (widget.onTap != null) action();
    if (!mounted || !widget.resetAfterCompletion) return;
    await _progress.animateBack(0, curve: Curves.easeOutCubic);
    if (mounted) setState(() => _committing = false);
  }

  void _release() {
    if (!_enabled) return;
    if (!_cancelled && _progress.value >= .9) {
      _complete();
    } else {
      _progress.animateBack(0, curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.onTap != null,
    label: widget.title,
    hint: 'Drag the handle to the right to continue',
    onTap: _enabled ? _complete : null,
    child: Listener(
      onPointerDown: (_) => _cancelled = false,
      onPointerCancel: (_) => _cancelled = true,
      child: FocusableActionDetector(
        enabled: _enabled,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _complete();
              return null;
            },
          ),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final travel = (constraints.maxWidth - 86).clamp(
              0.0,
              double.infinity,
            );
            return AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => Opacity(
                opacity: widget.onTap == null ? .45 : 1,
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppTheme.mist,
                    borderRadius: BorderRadius.circular(60),
                    border: _focused
                        ? Border.all(color: const Color(0xFF73BFE5), width: 2)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 87, right: 14),
                          child: Opacity(
                            opacity: (1 - _progress.value * 1.5).clamp(
                              0.0,
                              1.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Color(0xFFBDC1C4),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Color(0xFF85898C),
                                ),
                                const Icon(Icons.chevron_right, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 7 + travel * _progress.value,
                        top: 7,
                        child: GestureDetector(
                          key: ValueKey('slide-handle-${widget.title}'),
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragStart: _enabled
                              ? (_) {
                                  _progress.stop();
                                  HapticFeedback.selectionClick();
                                }
                              : null,
                          onHorizontalDragUpdate: _enabled && travel > 0
                              ? (details) {
                                  _progress.value += details.delta.dx / travel;
                                }
                              : null,
                          onHorizontalDragEnd: _enabled
                              ? (_) => _release()
                              : null,
                          onHorizontalDragCancel: _enabled
                              ? () => _progress.animateBack(0)
                              : null,
                          child: Container(
                            width: 72,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.ink,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              _committing ? Icons.check_rounded : widget.icon,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(
    this.title, {
    super.key,
    required this.onBack,
    this.trailing,
  });
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
    child: Row(
      children: [
        RoundButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
          label: 'Back',
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              letterSpacing: -.7,
            ),
          ),
        ),
        trailing ?? const SizedBox(width: 48),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: const BoxDecoration(
              color: AppTheme.mist,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 42),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.6),
          ),
          if (action != null) ...[const SizedBox(height: 26), action!],
        ],
      ),
    ),
  );
}

Route<T> coffeeRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 480),
  reverseTransitionDuration: const Duration(milliseconds: 350),
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .06),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  },
);
