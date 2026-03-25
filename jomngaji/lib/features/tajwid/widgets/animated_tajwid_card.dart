import 'package:flutter/material.dart';

class AnimatedTajwidCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedTajwidCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedTajwidCard> createState() => _AnimatedTajwidCardState();
}

class _AnimatedTajwidCardState extends State<AnimatedTajwidCard> {
  double scale = 1.0;

  void _onTapDown(_) {
    setState(() => scale = 0.96);
  }

  void _onTapUp(_) {
    setState(() => scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
