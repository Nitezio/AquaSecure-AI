import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ThreatFrame extends StatefulWidget {
  const ThreatFrame({required this.active, required this.child, super.key});

  final bool active;
  final Widget child;

  @override
  State<ThreatFrame> createState() => _ThreatFrameState();
}

class _ThreatFrameState extends State<ThreatFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ThreatFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final opacity = widget.active ? 0.48 + _controller.value * 0.42 : 0.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.danger.withValues(alpha: opacity),
              width: widget.active ? 3 : 0,
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: opacity * 0.18),
                      blurRadius: 25,
                      spreadRadius: 3,
                      blurStyle: BlurStyle.inner,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
