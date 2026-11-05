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

class SlideAction extends StatelessWidget {
  const SlideAction({
    super.key,
    required this.title,
    required this.onTap,
    this.icon = Icons.arrow_forward_ios_rounded,
  });
  final String title;
  final VoidCallback? onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Pressable(
    label: title,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppTheme.mist,
        borderRadius: BorderRadius.circular(60),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 60,
            decoration: const BoxDecoration(
              color: AppTheme.ink,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFBDC1C4)),
          const Icon(Icons.chevron_right, color: Color(0xFF85898C)),
          const Icon(Icons.chevron_right),
          const SizedBox(width: 12),
        ],
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
